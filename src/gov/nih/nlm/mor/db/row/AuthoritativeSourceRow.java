package gov.nih.nlm.mor.db.row;

import org.json.JSONObject;

public class AuthoritativeSourceRow {
	private Integer primarykey = -1;
	private String sourcename = null;
	private String description = null;
	private String user = "";
	private String date = "";
	private String updateDate = "";
	private String active = "";
	
	AuthoritativeSourceRow(JSONObject j) {
		
	}
	
	AuthoritativeSourceRow() {
		
	}
	
	private String getRowString() {
		String row = "";
		
		return row;
	}	

	public Integer getPrimarykey() {
		return primarykey;
	}

	public void setPrimarykey(Integer primarykey) {
		this.primarykey = primarykey;
	}

	public String getSourcename() {
		return sourcename;
	}

	public void setSourcename(String sourcename) {
		this.sourcename = sourcename;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getUser() {
		return user;
	}

	public void setUser(String user) {
		this.user = user;
	}

	public String getDate() {
		return date;
	}

	public void setDate(String date) {
		this.date = date;
	}

	public String getUpdateDate() {
		return updateDate;
	}

	public void setUpdateDate(String updateDate) {
		this.updateDate = updateDate;
	}

	public String getActive() {
		return active;
	}

	public void setActive(String active) {
		this.active = active;
	}

}
