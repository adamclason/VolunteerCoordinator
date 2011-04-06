String.prototype.trim = function () {
    return this.replace(/^\s*/, "").replace(/\s*$/, "");
}

function handleErrors() { //Checks for errors in the form before sending to the servlet
	var noErrs = true;
	var div;
	var title = document.forms["eventForm"]["newTitle"].value;
	title = title.trim();
	
	//Make sure title isn't blank
	if (title==null || title=="") {
		div = document.getElementById("titleError");
		div.innerHTML = "Please give the job a name.";
		noErrs = false;
	} else {
		div = document.getElementById("titleError");
		div.innerHTML = "";
	}

	//Make sure title doesn't contain one of the following invalid characters: \ / : * ? " < > | & #  
	if ( (title.indexOf("\\") !=-1) || (title.indexOf("/") !=-1) || (title.indexOf(":") !=-1) || (title.indexOf("*") !=-1) || (title.indexOf("?") !=-1) || (title.indexOf("\"") !=-1) || (title.indexOf("<") !=-1) || (title.indexOf(">") !=-1) || (title.indexOf("&") !=-1) || (title.indexOf("|") !=-1) || (title.indexOf("#") !=-1) ) {
		div = document.getElementById("charError");
		div.innerHTML = "Job title cannot contain one of the following invalid characters: \\ / : * ? \" < > | & # ";
		noErrs = false;
	} else {
		div = document.getElementById("charError");
		div.innerHTML = "";
	}
	
	//Make sure date isn't blank
	var date = document.forms["eventForm"]["when"].value;
	if (date==null || date=="") {
		div = document.getElementById("dateError");
		div.innerHTML = "Please enter a date.";
	    noErrs = false;
	} else {
		div = document.getElementById("dateError");
		div.innerHTML = "";
	}
	
	//Get starting time in minutes
	var fromHrs = parseInt(document.forms["eventForm"]["fromHrs"].value, 10);
	var fromMins = parseInt(document.forms["eventForm"]["fromMins"].value, 10);
	var fromAMPM = document.forms["eventForm"]["fromAMPM"].value;
	if (fromAMPM == "PM") { //Adjust if it's PM
		fromHrs = fromHrs + 12;
	}
	var fromTime = (fromHrs*60) + fromMins;
	
	//Get ending time in minutes
	var tillHrs = parseInt(document.forms["eventForm"]["tillHrs"].value, 10);
	var tillMins = parseInt(document.forms["eventForm"]["tillMins"].value, 10);
	var tillAMPM = document.forms["eventForm"]["toAMPM"].value;
	if (tillAMPM == "PM") { //Adjust if it's PM
		tillHrs = tillHrs + 12;
	}
	var tillTime = (tillHrs*60) + tillMins;
	
	//Make sure ending time isn't before starting time
	if (fromTime > tillTime) {
		div = document.getElementById("timeError");
		div.innerHTML = "Start time must be less than or equal to end time.";
	    noErrs = false;
	} else {
		div = document.getElementById("timeError");
		div.innerHTML = "";
	}
	
	if (noErrs) { //If no errors, go to servlet and update event
		document.forms["eventForm"].submit();
	}
}