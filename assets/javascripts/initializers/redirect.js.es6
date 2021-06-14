import { withPluginApi } from 'discourse/lib/plugin-api'

function createElementFromHtmlString(htmlString) {
  const div = document.createElement('div')
  div.innerHTML = htmlString.trim()
  return div.removeChild(div.firstChild)
}

function initialize(api, siteSettings) {
  const currentUser = api.getCurrentUser()

  if (currentUser !== null && window.self !== window.top && window.location.pathname === '/') {
    const apiKey = siteSettings.skillways_discourse_bridge_api_key
    const apiUser = siteSettings.skillways_discourse_bridge_api_user

    async function handleMessage(event) {
      if (event.data.type === 'PROVIDE_DISCUSSION_CONTEXT_INFORMATION') {
        const { uniqueCategoryIdentifier } = event.data

        const headers = {
          'Api-Key': apiKey,
          'Api-Username': apiUser,
          'Accept': 'application/json'
        }

        // get the category by name
        const getCategoryByNameResponse = await (
          fetch(`/c/${uniqueCategoryIdentifier}.json`, { method: 'GET', headers })
        )
        if (getCategoryByNameResponse.status === 200) {
          const getCategoryByNameResponseJson = await (getCategoryByNameResponse.json())

          // Redirect the user
          if (typeof getCategoryByNameResponseJson.topic_list !== 'undefined') {
            if (getCategoryByNameResponseJson.topic_list.topics.length < 2) {
              window.location = `/t/${getCategoryByNameResponseJson.topic_list.topics[0].id}`
            } else {
              window.location = `/c/${uniqueCategoryIdentifier}`
            }
          }
        }
      }
    }
    window.addEventListener('message', handleMessage, false)

    // Ask for the information needed to clone a context-based discussion from a template if needed, and do the
    // redirect to the correct location in the context-based discussion.
    window.parent.postMessage({ type: 'REQUEST_DISCUSSION_CONTEXT_INFORMATION' }, '*')

    const loadingIndicator = createElementFromHtmlString(
      `<div style="display: block; background-color: white; width: 100%; height: 100%; border: 0; position: absolute; top: 0; left: 0; z-index: 1001;">`
      + `<div style="font-size: 2em; margin: 30vh auto; height: 2em; text-align: center; width: 25em;">`
      + `<div class="spinner" style="display: inline-block; width: 0.5em; height: 0.5em; margin: 0; border: 4px solid black; border-radius: 50%; border-right-color: transparent;"></div> Preparing discussion &hellip;`
      + `</div>`
      + `</div>`
    )
    document.body.appendChild(loadingIndicator)
  }
}

export default {
  name: 'redirect',
  initialize(container) {
    const siteSettings = container.lookup('site-settings:main')
    if (siteSettings.skillways_discourse_bridge_enabled) {
      withPluginApi('0.11.1', api => {
        initialize(api, siteSettings)
      });
    }
  }
}
