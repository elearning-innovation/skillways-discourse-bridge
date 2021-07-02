import { getOwner } from 'discourse-common/lib/get-owner'

export default {
  // the _ is used as a reference to a parameter that is not needed
  setupComponent(_, component) {
    // this is triggered when the jwt SSO plugin wants to create an account
    // our handler attempts to submit the account creation "speed bump" for new users
    component.didRender = function createAccountDidRender() {
      setTimeout(function triggerCreateAccount() {
        const controller = getOwner(this).lookup('controller:create-account')
        // controller.send('createAccount')
        console.log('going to send')
      }, 2500)
    }
  }
}
