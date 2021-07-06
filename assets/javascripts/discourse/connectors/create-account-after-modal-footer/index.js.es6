import { getOwner } from 'discourse-common/lib/get-owner'

export default {
  setupComponent(_args, component) {
    // this is triggered when the jwt SSO plugin wants to create an account
    // our handler attempts to submit the account creation "speed bump" for new users
    component.didRender = function createAccountDidRender() {
      setInterval(function triggerCreateAccount() {
        try {
          const controller = getOwner(this).lookup('controller:create-account')
          controller.send('createAccount')
        } catch (_error) {
          return;
        }
      }, 100)
    }
  }
}
