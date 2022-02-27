import QtQuick 2.0

Item {
    property string mag: qsTr("M", "Magnetic North")

    property string north: qsTr("N", "North")
    property string south: qsTr("S", "South")
    property string east: qsTr("E", "East")
    property string west: qsTr("W", "West")

    function roundToDecimal(inputNum, numPoints) {
        var multiplier = Math.pow(10, numPoints);
        return Math.round(inputNum * multiplier) / multiplier;
    }

    function decimalToDMS(location, hemisphere, numSecondPoints) {
        if(location < 0) {
            location *= -1
        }
        var degrees = Math.floor(location);
        var minutesFromRemainder = (location - degrees) * 60;
        var minutes = Math.floor(minutesFromRemainder);
        var secondsFromRemainder = (minutesFromRemainder - minutes) * 60;
        var seconds = roundToDecimal(secondsFromRemainder, numSecondPoints);
        return degrees + '° ' + minutes + "' " + seconds + '" ' + hemisphere;
    }

    function decimalLatToDMS(location, numSecondPoints) {
        var hemisphere = (location < 0) ? south: north;
        return decimalToDMS(location, hemisphere, numSecondPoints);
    }

    function decimalLongToDMS(location, numSecondPoints) {
        var hemisphere = (location < 0) ? west : east;
        return decimalToDMS(location, hemisphere, numSecondPoints);
    }

    function formatDirection(direction) {
        var dirStr;
        if (direction < 11.25) {
            dirStr = north
        } else if (direction < 33.75) {
            dirStr = qsTr("NNE", "North North East")
        } else if (direction < 56.25) {
            dirStr = qsTr("NE", "North East")
        } else if (direction < 78.75) {
            dirStr = qsTr("ENE", "East North East")
        } else if (direction < 101.25) {
            dirStr = east
        } else if (direction < 123.75) {
            dirStr = qsTr("ESE", "East South East")
        } else if (direction < 146.25) {
            dirStr = qsTr("SE", "South East")
        } else if (direction < 168.75) {
            dirStr = qsTr("SSE", "South South East")
        } else if (direction < 191.25) {
            dirStr = south
        } else if (direction < 213.75) {
            dirStr = qsTr("SSW", "South South West")
        } else if (direction < 236.25) {
            dirStr = qsTr("SW", "South West")
        } else if (direction < 258.75) {
            dirStr = qsTr("WSW", "West South West")
        } else if (direction < 281.25) {
            dirStr = west
        } else if (direction < 303.75) {
            dirStr = qsTr("WNW", "West North West")
        } else if (direction < 326.25) {
            dirStr = qsTr("NW", "Norh West")
        } else if (direction < 348.75) {
            dirStr = qsTr("NNW", "North North West")
        } else if (direction < 360) {
            dirStr = north
        } else {
            dirStr = "?"
        }
        return dirStr === "?" ? "-" : dirStr + " (" + roundToDecimal(direction, 0) + "°)"
    }
}
