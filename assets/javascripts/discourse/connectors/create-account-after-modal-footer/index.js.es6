import { getOwner } from 'discourse-common/lib/get-owner'

export default {
  setupComponent(_, component) {
    component.didRender = function createAccountAfterInsert() {
      const controller = getOwner(this).lookup('controller:create-account');
      setInterval(function triggerCreateAccount() {
        controller.send('createAccount')
      }, 500)
    }
  }
}
