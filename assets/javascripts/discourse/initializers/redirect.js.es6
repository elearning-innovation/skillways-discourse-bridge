import { ajax } from 'discourse/lib/ajax'
import { withPluginApi } from 'discourse/lib/plugin-api'

function createElementFromHtml(htmlString) {
  var div = document.createElement('div')
  div.innerHTML = htmlString.trim()
  return div.removeChild(div.firstChild)
}

function initialize(api, siteSettings) {
  console.log(siteSettings.skillways_api_key)
  console.log(siteSettings.skillways_api_user)
  console.log(siteSettings.skillways_enabled)

  const currentUser = api.getCurrentUser()

  function getCategory(categoryId) {
    return ajax(`/c/${categoryId}`, {type: 'GET'})
  }

  function createCategory(name) {
    console.log('creating category')
    const response = ajax('/categories.json', {
      type: 'POST',
      data: {name}
    })

    response.then(response => console.log(response))
  }

  function handleMessage(event) {
    if (event.data.type === 'PROVIDE_DISCUSSION_CONTEXT_INFORMATION') {
      const {
        ltiResourceUniqueCategoryIdentifier,
        templateCategoryId
      } = event.data

      // check if the category exists
      ajax('/search.json', {
        type: 'GET',
        data: {q: ltiResourceUniqueCategoryIdentifier}
      })
        .then(searchResultsJson => {
          if (searchResultsJson.categories.length === 0) {
            return getCategory(templateCategoryId)
              .then(templateCategory => {
                console.log(templateCategory)

                createCategory(ltiResourceUniqueCategoryIdentifier)
              })
          }
        })
    }
  }
  window.addEventListener('message', handleMessage)

  if (currentUser !== null && window.self !== window.top && window.location.pathname === '/') {
    // Ask for the information needed to clone a context-based discussion from a template if needed, and do the
    // redirect to the correct location in the context-based discussion.
    window.parent.postMessage({type: 'REQUEST_DISCUSSION_CONTEXT_INFORMATION'}, '*')

    // window.parent.postMessage({type: 'REDIRECT_REQUEST'}, '*')

    if (currentUser.admin !== true) {
      const loadingIndicator = createElementFromHtml(
        `<div style="display: block; background-color: white; width: 100%; height: 100%; border: 0; position: absolute; top: 0; left: 0; z-index: 1001;">`
        + `<div style="font-size: 2em; margin: 30vh auto; height: 2em; text-align: center; width: 25em;">`
        + `<div class="spinner" style="display: inline-block; width: 0.5em; height: 0.5em; margin: 0; border: 4px solid black; border-radius: 50%; border-right-color: transparent;"></div> Preparing discussion &hellip;`
        + `</div>`
        + `</div>`
      )
      document.body.appendChild(loadingIndicator)
    }
  }
}

export default {
  name: 'redirect',
  initialize(container) {
    const siteSettings = container.lookup('site-settings:main')
    if (siteSettings.skillways_enabled) {
      withPluginApi('0.11.1', api => {
        initialize(api, siteSettings)
      });
    }
  }
}
