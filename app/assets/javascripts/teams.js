jQuery(function ($) {

    /**
     * EXPAND / COLLAPSE TEAMS
     */
    $(document).on('click', '.js-expand-all-teams', function (event) {
        event.preventDefault();

        $('.toggle-team-members').prop('checked', true);
    });

    $(document).on('click', '.js-collapse-all-teams', function (event) {
        event.preventDefault();

        $('.toggle-team-members').prop('checked', false);
    });

    $(document).on('change', '.js-submit-form-on-select', function () {
        $(this).closest('form').trigger('submit');
    });

    // Track all changes to the sort order
    var sortOrder = $(document)
        .onAsObservable('change', '.js-reorder-on-change')
        .map(function (event) {
            return $(event.target).val();
        });

    // Replace / add the "sort" query parameter and reload the page
    var reloadWithNewOrder = function(order) {
        window.location.search = 'order=' + order;
    };

    sortOrder.subscribe(reloadWithNewOrder);

});
