import { withPluginApi } from 'discourse/lib/plugin-api';

export default {
  name: 'redirect',
  initialize() {
    withPluginApi('0.11.1', api => {
      const currentUser = api.getCurrentUser();
      if (currentUser !== null) {
        window.parent.postMessage({type: 'REDIRECT_REQUEST'}, '*')
      }
    });
  }
};
