package gov.nih.nlm.mor.db.table;

import java.io.PrintWriter;
import java.util.ArrayList;

import gov.nih.nlm.mor.db.row.ConceptTypeRow;

public class ConceptTypeTable {
	private int primarykey = -1;
	private int codegenerator = 1;	
	private ArrayList<ConceptTypeRow> conceptTypeRows = new ArrayList<ConceptTypeRow>();
	
	
	public ConceptTypeTable() {
		
	}
	
	public void print(PrintWriter pw ) {
		
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
	public ArrayList<ConceptTypeRow> getConceptTypeRows() {
		return conceptTypeRows;
	}
	public void setConceptTypeRows(ArrayList<ConceptTypeRow> conceptTypeRows) {
		this.conceptTypeRows = conceptTypeRows;
	}	

}
