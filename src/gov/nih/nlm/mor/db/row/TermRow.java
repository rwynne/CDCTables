package gov.nih.nlm.mor.db.row;

import org.json.JSONObject;

public class TermRow {
	private String termname = "";
	private String ttyId = "";
	private String drugExternalId = "";
	private String authoritativeSource = "";
	private String creationUserId = "";
	private String creationDate = "";
	private String updatedUserId = "";
	private String updatedDate = "";
	private String isActive = "";
	
	public TermRow(JSONObject j) {
		
	}
	
	public TermRow() {
		
	}
	
	private String getRowString() {
		String row = "";
		
		return row;
	}	

	public String getTermname() {
		return termname;
	}

	public void setTermname(String termname) {
		this.termname = termname;
	}

	public String getTtyId() {
		return ttyId;
	}

	public void setTtyId(String ttyId) {
		this.ttyId = ttyId;
	}

	public String getDrugExternalId() {
		return drugExternalId;
	}

	public void setDrugExternalId(String drugExternalId) {
		this.drugExternalId = drugExternalId;
	}

	public String getAuthoritativeSource() {
		return authoritativeSource;
	}

	public void setAuthoritativeSource(String authoritativeSource) {
		this.authoritativeSource = authoritativeSource;
	}

	public String getCreationUserId() {
		return creationUserId;
	}

	public void setCreationUserId(String creationUserId) {
		this.creationUserId = creationUserId;
	}

	public String getCreationDate() {
		return creationDate;
	}

	public void setCreationDate(String creationDate) {
		this.creationDate = creationDate;
	}

	public String getUpdatedUserId() {
		return updatedUserId;
	}

	public void setUpdatedUserId(String updatedUserId) {
		this.updatedUserId = updatedUserId;
	}

	public String getUpdatedDate() {
		return updatedDate;
	}

	public void setUpdatedDate(String updatedDate) {
		this.updatedDate = updatedDate;
	}

	public String getIsActive() {
		return isActive;
	}

	public void setIsActive(String isActive) {
		this.isActive = isActive;
	}


}
