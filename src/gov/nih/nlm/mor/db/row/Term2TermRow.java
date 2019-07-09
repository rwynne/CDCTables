package gov.nih.nlm.mor.db.row;

import org.json.JSONObject;

public class Term2TermRow {
	private int primarykey = -1;
	private int codegenerator = 1;	
	private int drugTermId1 = -1;
	private String relation = "";
	private int drugTermId2 = -1;
	private String creationUserId = "";
	private String creationDateTime = "";
	private String updatedUserId = "";
	private String updatedDateTime = "";
	private String isActive = "";
	
	public Term2TermRow(JSONObject j) {
		
	}
	
	public Term2TermRow() {
		
	}
	
	
	private String getRowString() {
		String row = "";
		
		return row;
	}	
	
	public int getPrimarykey() {
		return primarykey;
	}
	public void setPrimarykey(int primarykey) {
		this.primarykey = primarykey;
	}
	public int getCodegenerator() {
		return codegenerator;
	}
	public void setCodegenerator(int codegenerator) {
		this.codegenerator = codegenerator;
	}
	public int getDrugTermId1() {
		return drugTermId1;
	}
	public void setDrugTermId1(int drugTermId1) {
		this.drugTermId1 = drugTermId1;
	}
	public String getRelation() {
		return relation;
	}
	public void setRelation(String relation) {
		this.relation = relation;
	}
	public int getDrugTermId2() {
		return drugTermId2;
	}
	public void setDrugTermId2(int drugTermId2) {
		this.drugTermId2 = drugTermId2;
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
