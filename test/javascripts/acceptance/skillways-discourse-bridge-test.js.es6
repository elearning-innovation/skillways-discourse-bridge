import { acceptance } from "discourse/tests/helpers/qunit-helpers";

acceptance("skillways-discourse-bridge", { loggedIn: true });

test("skillways-discourse-bridge works", async assert => {
  await visit("/admin/plugins/skillways-discourse-bridge");

  assert.ok(false, "it shows the skillways-discourse-bridge button");
});
