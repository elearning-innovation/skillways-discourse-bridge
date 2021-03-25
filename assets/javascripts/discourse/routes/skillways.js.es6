import DiscourseRoute from 'discourse/routes/discourse';

/**
 * Route for the path `/skillways` as defined in `../skillways-route-map.js.es6`.
 */
export default DiscourseRoute.extend({
  renderTemplate() {
    // Renders the template `../templates/skillways.hbs`
    this.render('skillways');
  }
});
