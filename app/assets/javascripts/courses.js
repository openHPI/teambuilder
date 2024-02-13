jQuery(function ($) {

    /**
     * TOGGLABLE FORM GROUPS
     */

    $(document).on('change', '.js-toggle-setting .toggle input', function () {
        var $target = $(this).closest('.js-toggle-setting');

        if (this.checked) {
            $target.addClass('enabled');
        } else {
            $target.removeClass('enabled');
        }
    });

    $('.js-toggle-setting .toggle input').each(function () {
        var $target = $(this).closest('.js-toggle-setting');

        $target.toggleClass('enabled', this.checked);
    });

    $(document).on('change', '.js-store-orig-value .toggle input', function () {
        var $target = $(this).closest('.js-store-orig-value');
        var $settings = $target.find('.settings');

        // Restore the state of the target to that as sent by the server.
        if (this.checked) {
            $settings.html($settings.data('original'));
        }
    });

    $('.js-store-orig-value .toggle input').each(function () {
        var $settings = $(this).closest('.js-store-orig-value').find('.settings');

        // Store the original settings HTML in a data attribute so
        // that we can restore it the next time this is toggled.
        $settings.data('original', $settings.html());
    });


    /**
     * PREVIEW LIVE UPDATES
     */

    var minSize = watchInputChanges('#min_size')
        .filter(validGroupSize);
    var maxSize = watchInputChanges('#max_size')
        .filter(validGroupSize);

    var minScoreEnabled = watchCheckboxChanges('#limiters_by_score');
    var minScore = watchInputChanges('#min_score');
    var maxParticipantsEnabled = watchCheckboxChanges('#limiters_by_number');
    var maxParticipants = watchInputChanges('#max_candidates');

    var avgGroupSize = minSize.combineLatest(maxSize, function (min, max) {
        return Math.round((parseInt(min) + parseInt(max)) / 2);
    });

    var passedApplicants = Rx.Observable.combineLatest(
        maxParticipantsEnabled,
        maxParticipants,
        minScoreEnabled,
        minScore,
        function(maxEnabled, max, scoreEnabled, score) {
            var passed;

            if (scoreEnabled) {
                passed = window.applicants.filter(function(applicant) {
                    return applicant.score >= score;
                }).length;
            } else {
                passed = window.applicants.length;
            }

            return maxEnabled ? Math.min(max, passed) : passed;
        }
    );

    var predictedTeamCount = Rx.Observable.combineLatest(passedApplicants, avgGroupSize, function (count, groupSize) {
        return Math.ceil(count / groupSize);
    });

    dumpToText(predictedTeamCount, '#team-count-prediction');
    dumpToText(passedApplicants, '#passed-applicants');

    if ($('#preview-graph').length) {
        passedApplicants.subscribe(function (passed) {
            var percentage = (passed / window.applicants.length) * 100;

            $('#preview-graph .passed').css('width', percentage + '%');
        });
    }

    /**
     * PREFERRED TASK MANAGEMENT
     */

    $(document).on('click', '.task .remove', function(event) {
        event.preventDefault();
        $(this).closest('.task').remove();
    });

    var newTaskSubmitted = watchKeypresses('.new-task input')
        .filter(enterPressed)
        .do(preventDefault)
        .map(function (event) {
            return event.target;
        });

    var listNewTask = function (taskInput) {
        var html = $('#template-new-task').html();
        html = html.replace(/{{task}}/g, taskInput.value);
        taskName = taskInput.closest('.preferred-tasks').getAttribute('data-task-name');
        html = html.replace(/{{name}}/g, taskName);

        $(html).insertBefore(taskInput.closest('li'));
    };

    var clearNewTaskField = function (taskInput) {
        taskInput.value = '';
    };

    newTaskSubmitted.subscribe(listNewTask);
    newTaskSubmitted.subscribe(clearNewTaskField);

    $(document).on('click', '#new-setting button', function (event) {
        var html = $('#template-new-setting').html();
        var lastCustomPreference = $('.course-settings-setting.custom-preference:last');

        // The `index` represents the n-th course-specific preference in the list
        // The `number` is the count displayed (offset by 1)
        var index = 0;
        if (lastCustomPreference.length) { index = lastCustomPreference.data('index') + 1 }
        var number = index + 1;

        html = html.replace(/{{index}}/g, index);
        html = html.replace(/{{number}}/g, number);

        if (lastCustomPreference.length) {
            $(html).insertAfter(lastCustomPreference);
        } else {
            var newSettingButton = $('#new-setting');
            $(html).insertBefore(newSettingButton);
        }
    });

    /**
     * PROMPT FOR COPYING COURSES
     */

    var copyFunction = function(e) {
        var button = $(e.target);
        var courseNameField = button.closest('form').find('.course_name');
        var newname = prompt('Enter the new course name:', courseNameField.val());
        if (newname == null) {
            e.preventDefault();
        }
        else if ('' === newname.trim()) {
            alert('Please enter a name for the copy!');
            e.preventDefault();
        }
        else {
            courseNameField.val(newname);
        }
    };

    $(".copy").on("click", copyFunction);


});
