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
	private String email; 

	@Persistent
	private String phone; 
	
	@Persistent
	private String reminder; 
	
	public Volunteer(String firstname, String lastname, String email, String phone, String reminder) {
		this.name = firstname.trim() + " " + lastname.trim();
		this.email = email; 
		this.phone = phone; 
		this.reminder = reminder;
	}
	
	public Key getKey() {
		return key; 
	}

}
