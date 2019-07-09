package gov.nih.nlm.mor.db.table;

import java.io.PrintWriter;
import java.util.ArrayList;

import gov.nih.nlm.mor.db.row.Concept2ConceptRow;
import gov.nih.nlm.mor.db.rxnorm.Concept;
import gov.nih.nlm.mor.db.rxnorm.ConceptRelationship;

public class Concept2ConceptTable {
	
	private ArrayList<ConceptRelationship> rows = new ArrayList<ConceptRelationship>();
	
	public Concept2ConceptTable() {
		
	}
	
	public void add(ConceptRelationship r) {
		this.rows.add(r);
	}	
	
	public void print(PrintWriter pw) {
		
	}
	
}
