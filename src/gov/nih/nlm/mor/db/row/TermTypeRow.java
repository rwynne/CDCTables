package gov.nih.nlm.mor.db.row;

import org.json.JSONObject;

public class TermTypeRow {
	private String abbreviation = "";
	private String description = "";
	private String creationid = "";
	private String creationdate = "";
	private String updateuserid = "";
	private String updatedate = "";
	private String isActive = "";
	
	public TermTypeRow(JSONObject j) {
		
	}
	
	public TermTypeRow() {
		
	}
	
	private String getRowString() {
		String row = "";
		
		return row;
	}	

	public String getAbbreviation() {
		return abbreviation;
	}

	public void setAbbreviation(String abbreviation) {
		this.abbreviation = abbreviation;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getCreationid() {
		return creationid;
	}

	public void setCreationid(String creationid) {
		this.creationid = creationid;
	}

	public String getCreationdate() {
		return creationdate;
	}

	public void setCreationdate(String creationdate) {
		this.creationdate = creationdate;
	}

	public String getUpdateuserid() {
		return updateuserid;
	}

	public void setUpdateuserid(String updateuserid) {
		this.updateuserid = updateuserid;
	}

	public String getUpdatedate() {
		return updatedate;
	}

	public void setUpdatedate(String updatedate) {
		this.updatedate = updatedate;
	}

	public String getIsActive() {
		return isActive;
	}

	public void setIsActive(String isActive) {
		this.isActive = isActive;
	}

}
