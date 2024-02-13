function watchInputChanges(selector) {
    return watchFor('input', selector, function ($field) { return $field.val(); });
}

function watchCheckboxChanges(selector) {
    return watchFor('change', selector, function ($field) { return $field.is(':checked'); });
}
function watchReset(selector){
    return watchFor('reset', selector).startWith($(selector));
}

function watchKeypresses(selector) {
    return watchFor('keypress', selector);
}

function watchFor(eventType, selector, valueMapper) {
    var stream = $(document)
        .onAsObservable(eventType, selector);

    if (valueMapper) {
        stream = stream
            .map(function(e) {
                return valueMapper($(e.target));
            })
            .startWith(valueMapper($(selector)));
    }

    return stream;
}

function enterPressed(event) {
    return event.which === 13;
}

function validGroupSize(value) {
    var intValue = parseInt(value);

    if (isNaN(intValue)) {
        return false;
    }

    return intValue > 0 && intValue < 100;
}

function preventDefault(event) {
    event.preventDefault();
}

function dumpToText(stream, selector) {
    dumpToNode(stream, selector, function ($target, data) { $target.text(data); });
}

function dumpToNode(stream, selector, valueSetter) {
    var $target = $(selector);

    if ($target.length) {
        stream.subscribe(function (data) {
            valueSetter($target, data);
        });
    }
}
