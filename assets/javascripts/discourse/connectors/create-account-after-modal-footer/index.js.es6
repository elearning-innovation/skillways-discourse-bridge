import { getOwner } from 'discourse-common/lib/get-owner'

export default {
  actions: {
    createAccount() {
      const controller = getOwner(this).lookup('controller:create-account');
      controller.send('createAccount')
    }
  }
}
