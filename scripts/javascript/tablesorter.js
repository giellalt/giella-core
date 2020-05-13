function myRowWriter(rowIndex, record, columns, cellWriter) {
    var tr = '';

    // grab the record's attribute for each column
    for (var i = 0, len = columns.length; i < len; i++) {
        tr += cellWriter(columns[i], record);
    }

    return '<tr corrsugg=' + record.customData + '>' + tr + '</tr>';
};

function myRowReader(rowIndex, rowElement, record) {
    record.customData = $(rowElement).attr('corrsugg');
};

$(document).ready(function(){$("#results").dynatable({features: {paginate: false},writers: {_rowWriter:myRowWriter},readers: {_rowReader: myRowReader},});});
