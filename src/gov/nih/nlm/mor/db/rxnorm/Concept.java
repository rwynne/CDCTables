package gov.nih.nlm.mor.db.rxnorm;

public class Concept {
	Double conceptId = null;
	Double preferredTermId = null;
	String source = "";
	String sourceId = "";
	String classType = "";
	
	public Concept() {
		
	}

	public Double getConceptId() {
		return conceptId;
	}

	public void setConceptId(Double conceptId) {
		this.conceptId = conceptId;
	}

	public Double getPreferredTermId() {
		return preferredTermId;
	}

	public void setPreferredTermId(Double preferredTermId) {
		this.preferredTermId = preferredTermId;
	}

	public String getSource() {
		return source;
	}

	public void setSource(String source) {
		this.source = source;
	}

	public String getSourceId() {
		return sourceId;
	}

	public void setSourceId(String sourceId) {
		this.sourceId = sourceId;
	}

	public String getClassType() {
		return classType;
	}

	public void setClassType(String classType) {
		this.classType = classType;
	}


}
