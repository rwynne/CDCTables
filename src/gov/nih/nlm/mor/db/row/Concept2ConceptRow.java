package gov.nih.nlm.mor.db.row;

import org.json.JSONObject;

public class Concept2ConceptRow {
	private Integer primaryKey = -1;
	private String drugConceptId1 = "";
	private String relation = "";
	private String drugConceptId2 = "";
	private String creationUserId = "";
	private String creationDateTime = "";
	private String updatedUserId = "";
	private String updatedDateTime = "";
	private String isActive = "";
	
	public Concept2ConceptRow(JSONObject j) {
		
	}
	
	public Concept2ConceptRow() {
		
	}
	
	private String getRowString() {
		String row = "";
		
		return row;
	}	
	
	public String getDrugConceptId1() {
		return drugConceptId1;
	}
	public void setDrugConceptId1(String drugConceptId1) {
		this.drugConceptId1 = drugConceptId1;
	}
	public String getRelation() {
		return relation;
	}
	public void setRelation(String relation) {
		this.relation = relation;
	}
	public String getDrugConceptId2() {
		return drugConceptId2;
	}
	public void setDrugConceptId2(String drugConceptId2) {
		this.drugConceptId2 = drugConceptId2;
	}
	public String getCreationUserId() {
		return creationUserId;
	}
	public void setCreationUserId(String creationUserId) {
		this.creationUserId = creationUserId;
	}
	public String getCreationDateTime() {
		return creationDateTime;
	}
	public void setCreationDateTime(String creationDateTime) {
		this.creationDateTime = creationDateTime;
	}
	public String getUpdatedUserId() {
		return updatedUserId;
	}
	public void setUpdatedUserId(String updatedUserId) {
		this.updatedUserId = updatedUserId;
	}
	public String getUpdatedDateTime() {
		return updatedDateTime;
	}
	public void setUpdatedDateTime(String updatedDateTime) {
		this.updatedDateTime = updatedDateTime;
	}
	public String getIsActive() {
		return isActive;
	}
	public void setIsActive(String isActive) {
		this.isActive = isActive;
	}

	

}
