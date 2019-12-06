package gov.nih.nlm.mor.db.rxnorm;

public class ConceptRelationship {
	Double id = null;
	Double conceptId1 = null;
	String relationship = "";
	Double conceptId2 = null;
	
	public ConceptRelationship() {
		
	}

	public Double getId() {
		return id;
	}

	public void setId(Double id) {
		this.id = id;
	}

	public Double getConceptId1() {
		return conceptId1;
	}

	public void setConceptId1(Double conceptId1) {
		this.conceptId1 = conceptId1;
	}

	public String getRelationship() {
		return relationship;
	}

	public void setRelationship(String relationship) {
		this.relationship = relationship;
	}

	public Double getConceptId2() {
		return conceptId2;
	}

	public void setConceptId2(Double conceptId2) {
		this.conceptId2 = conceptId2;
	}
}
