package com.VolunteerCoordinatorApp;

import com.google.appengine.api.datastore.Key;

import java.util.Date;
import java.util.List;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

@PersistenceCapable
public class Event {
	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key; 
	
	@Persistent
	private String description; 
	
	@Persistent 
	private Date date; 

	@Persistent 
	private Date dateAdded; 

	@Persistent 
	private List<Volunteer> volunteers; 
	
	@Persistent 
	private int numVolunteersNeeded; 
	
	@Persistent 
	private int numVolunteers; 
	
	
	public Event(String description, Date date, int numVolunteersNeeded) {
		this.description = description; 
		this.date = date;
		this.dateAdded = new Date(); 
		this.numVolunteersNeeded = numVolunteersNeeded;
		numVolunteers = 0; 
	
	}

	public List<Volunteer> getVolunteers() {
		return volunteers;
	}

	public void setVolunteers(List<Volunteer> volunteers) {
		this.volunteers = volunteers;
	}

	public Key getKey() {
		return key;
	}

	public void setKey(Key key) {
		this.key = key;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public Date getDate() {
		return date;
	}

	public void setDate(Date date) {
		this.date = date;
	}

	public Date getDateAdded() {
		return dateAdded;
	}

	public void setDateAdded(Date dateAdded) {
		this.dateAdded = dateAdded;
	}
	
	
	
}
