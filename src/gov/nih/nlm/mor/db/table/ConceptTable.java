package gov.nih.nlm.mor.db.table;

import java.io.PrintWriter;
import java.util.ArrayList;

import org.json.JSONObject;

import gov.nih.nlm.mor.db.row.ConceptRow;
import gov.nih.nlm.mor.db.rxnorm.Concept;

public class ConceptTable {

	private ArrayList<Concept> rows = new ArrayList<Concept>();
	
	public ConceptTable() {
		
	}
	
	public void add(Concept c) {
		rows.add(c);
	}
	
	public void print(PrintWriter pw) {
		
	}	

}
