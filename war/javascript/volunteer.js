$(document).ready(function() {
	$('#filterButton').click(function() {
		$('#filterSettings').slideToggle('slow', function() {
			// Animation Complete
		}); 
		
		if($('#rangeCheckbox').attr('checked')) { 
			$('#textboxes').show(); 
		}
		else {
			$('#textboxes').hide(); 
		}
			
		
		if($('#categoryCheckbox').attr('checked')) { 
			$('#categorySelect').show(); 
		}
		else {
			$('#categorySelect').hide(); 
		}
			
		
	});
	
	
	$('#rangeCheckbox').click(function() { 
		$('#textboxes').toggle(); 
	});
	
	$('#categoryCheckbox').click(function() { 
		$('#categorySelect').toggle(); 
	}); 	
	
	$('#startRange').datepicker(); 
	
	$('#endRange').datepicker(); 
	
	
}); 		