var FLOAT_MAXVALUE =  1000;
// used if in editing mode => process element's value if submit clicked
function submitOnClick()
{
    var i;
    var t = document.forms[0].elements.length;
    var checkBoxID = null;
    var ids = java.lang.reflect.Array.newInstance(java.lang.String, t);
    var elements = java.lang.reflect.Array.newInstance(java.lang.String, t);
    var values = java.lang.reflect.Array.newInstance(java.lang.String, t);
    for (i = 0; i < t; i++) {// a t -edik maga a button!!! ha 1 van
        var value;
        var doUpdate = true;
// Select
        if (document.forms[0].elements[i].type == "select-one") {
// Counts from 0; work only if singleselection!!!
            var sel = document.forms[0].elements[i].selectedIndex;
            value = document.forms[0].elements[i].options[sel].value;
        }
// Radio button
        else if (document.forms[0].elements[i].type == "radio") {
            if (document.forms[0].elements[i].checked) {
                doUpdate = true;
                value = document.forms[0].elements[i].value;
            }
            else {
                doUpdate = false;
            }
        }
// Checkbox. Checkboxes in the same group has the same id.
        else if (document.forms[0].elements[i].type == "checkbox") {
            if (document.forms[0].elements[i].checked) {
                doUpdate = true;
    // Concatenate checked values in a checkbox group.
                if (checkBoxID == document.forms[0].elements[i].id) {
                    value = (value == null || value == '') ? document.forms[0].elements[i].value : value + ", " + document.forms[0].elements[i].value;
                }
                else {
                    value = document.forms[0].elements[i].value;
                }
    // Store current checkbox id to track checkbox group changes if the current form element is checked.
                checkBoxID = document.forms[0].elements[i].id;
            }
            else {
                doUpdate = false;
            }
        }
        else {
            value = document.forms[0].elements[i].value;
        }
        if (doUpdate) {
			ids[i] = document.forms[0].elements[i].id;
            elements[i] = document.forms[0].elements[i].name;
            values[i] = value;
        }
    }
    if (navigator.appName == "Microsoft Internet Explorer") {
        parent.rptToolFrame.document.ReportingToolApplet.updateDOMValue(ids, elements, values);
    }
    if (navigator.appName == "Mozilla" || navigator.appName == "Netscape") {
        parent.rptToolFrame.document.embeds['ReportingToolApplet'].updateDOMValue(ids, elements, values);
    }
}
// numeric input validation
var previous = "";
function store(val) {
    previous = val;
}

function validateChar(input) {
    var newValue = "";
    for (i = 0; i < input.value.length; ++i) {
        chCode = input.value.charCodeAt(i);
        if (chCode == 10 || chCode == 13 || (chCode >= 32 && chCode <= 126) || (chCode >= 160 && chCode <= 255)) {
            newValue = newValue + input.value.charAt(i);
        }
    }
    input.value = newValue;
}

function validateNum(input) {
    if ( isNaN(input.value) ) {
        input.value = previous;
    }
    else {
// space is accepted here => remove
        input.value = input.value.replace(/\s/,"");
        if (input.value > FLOAT_MAXVALUE) {
             input.value = previous;
             return false;
        }
        else {
            previous = input.value;
        }
        return true;
    }
    return false;
}

function validateDate(input) {
    if (input.value == "" || input.value.length < 10) {
        input.value = previous;
        alert(MSG_LEAVE_BLANK);
        return false;
    }
    else {
        var pattern=/^\d{4}-(0[1-9]|1[0-2])-(0[1-9]|1[0-9]|2[0-9]|3[0-1])$/;
        if (!pattern.test(input.value) ){
            input.value = previous;
            alert(MSG_WRONG_DATE_FORMAT);
            return false;
        }
        else {
//check for date validity
            var year = input.value.substr(0,4);
            var month = input.value.substr(5,2);
            var day = input.value.substr(8,2);
            if (day == 31 && (month == 4 || month == 6 || month == 9 || month == 11) ) {
                input.value = previous;
                alert(MSG_WRONG_DATE_FORMAT);
                return false;
            }
            else {
                if (day >= 30 && month == 2) {
                    input.value = previous;
                    alert(MSG_WRONG_DATE_FORMAT);
                    return false;
                }
                else {
                    if (month == 2 && day == 29 && !(year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))) {
                        input.value = previous;
                        alert(MSG_WRONG_DATE_FORMAT);
                        return false;
                    }
                }
            }
        }
    }
    return true;
}

// Validates Time fields to have HH:MM:SS format.
function validateTime(input) {
    if (input.value == "" || input.value.length < 8) {
        input.value = previous;
        alert(MSG_LEAVE_BLANK);
        return false;
    }
}

// Validates DateTime fields to have YYYY-MM-DDTHH:MM:SS format.
function validateDateTime(input) {
    if (input.value == "" || input.value.length < 19) {
        input.value = previous;
        alert(MSG_LEAVE_BLANK);
        return false;
    }
}
