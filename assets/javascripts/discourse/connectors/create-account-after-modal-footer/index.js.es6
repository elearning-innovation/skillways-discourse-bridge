import { getOwner } from 'discourse-common/lib/get-owner'

export default {
  setupComponent(_, component) {
    component.didRender = function createAccountDidRender() {
      setTimeout(function triggerCreateAccount() {
        const controller = getOwner(this).lookup('controller:create-account')
        controller.send('createAccount')
      }, 2500)
    }
  }
}
