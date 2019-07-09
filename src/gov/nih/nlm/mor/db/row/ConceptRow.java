package gov.nih.nlm.mor.db.row;

import org.json.JSONObject;

public class ConceptRow {
	private int primarykey = -1;
	private int codegenerator = 1;	
	private String preferredTermId = "";
	private String drugAuthoratativeSourceId = "";
	private String drugConceptTypeId = "";
	private String drugSourceConceptId = "";
	private String creationDate ="";
	private String creationUserId = "";
	private String updateDate = "";
	private String updateUserId = "";
	private String idActive = "";
	
	public ConceptRow(JSONObject j) {
		
	}
	
	public ConceptRow() {
		
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
	public String getPreferredTermId() {
		return preferredTermId;
	}
	public void setPreferredTermId(String preferredTermId) {
		this.preferredTermId = preferredTermId;
	}

	public String getDrugAuthoratativeSourceId() {
		return drugAuthoratativeSourceId;
	}

	public void setDrugAuthoratativeSourceId(String drugAuthoratativeSourceId) {
		this.drugAuthoratativeSourceId = drugAuthoratativeSourceId;
	}

	public String getDrugConceptTypeId() {
		return drugConceptTypeId;
	}

	public void setDrugConceptTypeId(String drugConceptTypeId) {
		this.drugConceptTypeId = drugConceptTypeId;
	}

	public String getDrugSourceConceptId() {
		return drugSourceConceptId;
	}

	public void setDrugSourceConceptId(String drugSourceConceptId) {
		this.drugSourceConceptId = drugSourceConceptId;
	}

	public String getCreationDate() {
		return creationDate;
	}

	public void setCreationDate(String creationDate) {
		this.creationDate = creationDate;
	}

	public String getCreationUserId() {
		return creationUserId;
	}

	public void setCreationUserId(String creationUserId) {
		this.creationUserId = creationUserId;
	}

	public String getUpdateDate() {
		return updateDate;
	}

	public void setUpdateDate(String updateDate) {
		this.updateDate = updateDate;
	}

	public String getUpdateUserId() {
		return updateUserId;
	}

	public void setUpdateUserId(String updateUserId) {
		this.updateUserId = updateUserId;
	}

	public String getIdActive() {
		return idActive;
	}

	public void setIdActive(String idActive) {
		this.idActive = idActive;
	}
	

}
