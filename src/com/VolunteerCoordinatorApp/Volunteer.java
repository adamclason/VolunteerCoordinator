package com.VolunteerCoordinatorApp;

import com.google.appengine.api.datastore.Key;
import com.google.appengine.api.users.User;


import java.util.Date;
import javax.jdo.annotations.IdGeneratorStrategy;
import javax.jdo.annotations.PersistenceCapable;
import javax.jdo.annotations.Persistent;
import javax.jdo.annotations.PrimaryKey;

@PersistenceCapable
public class Volunteer {
	@PrimaryKey
	@Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	private Key key; 

	@Persistent
	private String name;
	
	@Persistent
	private String firstName;
	
	@Persistent
	private String lastName;
	
	@Persistent
	private String email; 

	@Persistent
	private String phone; 
	
	@Persistent
	private String reminder; 
	
	@Persistent
	private String calendarId;
	
	@Persistent
	private String timeZone;
	
	public Volunteer(String firstname, String lastname, String email, String phone, 
	        String reminder, String calendarId, String timeZone) {
		this.name = firstname.trim() + " " + lastname.trim();
		this.firstName = firstname; 
		this.lastName = lastname;
		this.email = email; 
		this.phone = phone; 
		this.reminder = reminder;
		this.calendarId = calendarId;
		this.timeZone = timeZone;
	}
	
	public Key getKey() {
		return key; 
	}

    public void setKey(Key key) {
        this.key = key;
    }

    public String getFirstName() {
    	return firstName;
    }

    public void setFirstName(String firstName) {
    	this.firstName = firstName;
    }
    
    public String getLastName() {
    	return lastName;
    }
    
    public void setLastName(String lastName) {
    	this.lastName = lastName;
    }

    public String getEmail() {
    	return email;
    }

    public void setEmail(String email) {
    	this.email = email;
    }
    
    public String getPhone() {
    	return phone;
    }
    
    public void setPhone(String phone) {
    	this.phone = phone;
    }
    
    public String getReminder() {
    	return reminder;
    }
    
    public void setReminder(String reminder) {
    	this.reminder = reminder;
    }
    
    public String getCalendarId() 
    {
        return calendarId;
    }
    
    public void setCalendarId(String calendarId) 
    {
        this.calendarId = calendarId;
    }
    
    public String getTimeZone() 
    {
        return this.timeZone;
    }
    
    public void setTimeZone(String timeZone) 
    {
        this.timeZone = timeZone;
    }
}
