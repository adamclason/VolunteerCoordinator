$(document).ready(function() {
	$('#filter').click(function() {
		$('#filterSettings').slideToggle('slow', function() {
			// Animation Complete
		}); 
	});
	
	$('#range').click(function() {
		$('#textboxes').toggle(); 
	}); 
	
	$('#startRange').datepicker(); 
	
	$('#endRange').datepicker(); 
}); 		