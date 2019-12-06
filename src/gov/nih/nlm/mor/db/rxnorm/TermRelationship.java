package gov.nih.nlm.mor.db.rxnorm;

public class TermRelationship {
	Double id = null;
	Double termId1 = null;
	String relationship = "";
	Double termId2 = null;
	
	public TermRelationship() {
		
	}

	public Double getId() {
		return id;
	}

	public void setId(Double id) {
		this.id = id;
	}

	public Double getTermId1() {
		return termId1;
	}

	public void setTermId1(Double termId1) {
		this.termId1 = termId1;
	}

	public String getRelationship() {
		return relationship;
	}

	public void setRelationship(String relationship) {
		this.relationship = relationship;
	}

	public Double getTermId2() {
		return termId2;
	}

	public void setTermId2(Double termId2) {
		this.termId2 = termId2;
	}	
	
	

}
