$(document).ready(function() {
	$('#filter').click(function() {
		$('#filterSettings').slideToggle('slow', function() {
			// Animation Complete
		}); 
		
		if($('#rangeCheckbox').attr('checked')) { 
			$('#textboxes').show(); 
		}
		else {
			$('#textboxes').hide(); 
		}
			
		
	});
	
	
	$('#rangeCheckbox').click(function() { 
		$('#textboxes').toggle(); 
	});
	
	$('#startRange').datepicker(); 
	
	$('#endRange').datepicker(); 
	
	
}); 		