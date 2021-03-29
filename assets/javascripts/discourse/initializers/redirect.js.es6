import { withPluginApi } from 'discourse/lib/plugin-api'

function createElementFromHtmlString(htmlString) {
  const div = document.createElement('div')
  div.innerHTML = htmlString.trim()
  return div.removeChild(div.firstChild)
}

function initialize(api, siteSettings) {
  const apiKey = siteSettings.skillways_discourse_bridge_api_key
  const apiUser = siteSettings.skillways_discourse_bridge_api_user

  const currentUser = api.getCurrentUser()

  async function handleMessage(event) {
    if (event.data.type === 'PROVIDE_DISCUSSION_CONTEXT_INFORMATION') {
      const {
        ltiResourceUniqueCategoryIdentifier,
        templateCategoryId
      } = event.data

      const headers = {
        'Api-Key': apiKey,
        'Api-Username': apiUser,
        'Accept': 'application/json'
      }

      // check if the category already exists
      const categoryExistsResponse = await (
        fetch(`/search.json?q=${ltiResourceUniqueCategoryIdentifier}`, {method: 'GET', headers})
          .then(response => response.json())
      )
      console.log('categoryExistsResponse', categoryExistsResponse)

      // create the category if it doesn't exist
      if (categoryExistsResponse.categories.length === 0) {
        // copy the template category
        const createCategoryResponse = await (
          fetch('/categories.json', {
            method: 'POST',
            headers: {...headers, 'Content-Type': 'application/json'},
            body: JSON.stringify({name: ltiResourceUniqueCategoryIdentifier})
          })
            .then(response => response.json())
        )
        console.log('createCategoryResponse', createCategoryResponse)

        // get the new category
        const newCategory = await (
          fetch(`/c/${createCategoryResponse.category.id}.json`, {method: 'GET', headers})
            .then(response => response.json())
        )
        console.log('newCategory', newCategory)

        // lookup the template category
        const templateCategoryResponse = await (
          fetch(`/c/${templateCategoryId}.json`, {method: 'GET', headers})
            .then(response => response.json())
        )
        console.log('templateCategoryResponse', templateCategoryResponse)

        // make sure the topics match
        for (const [topicIndex, topicData] of templateCategoryResponse.topic_list.topics.entries()) {
          // get the topic from the template category
          const templateTopic = await (
            fetch(`/t/${topicData.id}.json`, {method: 'GET', headers})
              .then(response => response.json())
          )
          console.log('templateTopic', templateTopic)

          // upate the initial topic in the newCategory
          if (topicIndex === 0) {
            // get the existing initial topic
            const initialTopic = await (
              fetch(`/t/${newCategory.topic_list.topics[0].id}.json`, {method: 'GET', headers})
                .then(response => response.json())
            )
            console.log('initialTopic', initialTopic)

            // update the title of the initial topic
            const updateInitialTopicResponse = await (
              fetch(`/t/-/${initialTopic.id}.json`, {
                method: 'PUT',
                headers: {...headers, 'Content-Type': 'application/json'},
                body: JSON.stringify({title: templateTopic.title})
              })
            )
            console.log('updateInitalTopicResponse', updateInitialTopicResponse)

            // update the first post in the initial topic
            const updateInitialPostResponse = await (
              fetch(`/posts/${initialTopic.post_stream.posts[0].id}.json`, {
                method: 'PUT',
                headers: {...headers, 'Content-Type': 'application/json'},
                body: JSON.stringify({post: {raw: templateTopic.post_stream.posts[0].cooked}})
              })
                .then(response => response.json())
            )
            console.log('updateInitialPostResponse', updateInitialPostResponse)
          } else {
            // make a copy of templateTopic within newCategory
            const createTopicResponse = await (
              fetch('/posts.json', {
                method: 'POST',
                headers: {...headers, 'Content-Type': 'application/json'},
                body: JSON.stringify({
                  title: templateTopic.title,
                  raw: templateTopic.post_stream.posts[0].cooked,
                  category: createCategoryResponse.category.id
                })
              })
                .then(response => response.json())
            )
            console.log('createTopicResponse', createTopicResponse)
          }
        }
      }

      // TODO: redirect the user
    }
  }
  window.addEventListener('message', handleMessage)

  if (currentUser !== null && window.self !== window.top && window.location.pathname === '/') {
    // Ask for the information needed to clone a context-based discussion from a template if needed, and do the
    // redirect to the correct location in the context-based discussion.
    window.parent.postMessage({type: 'REQUEST_DISCUSSION_CONTEXT_INFORMATION'}, '*')

    if (currentUser.admin !== true) {
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
