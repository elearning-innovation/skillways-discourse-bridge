export default function() {
  this.route("skillways-discourse-bridge", function() {
    this.route("actions", function() {
      this.route("show", { path: "/:id" });
    });
  });
};
