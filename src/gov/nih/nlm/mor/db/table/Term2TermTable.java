package gov.nih.nlm.mor.db.table;

import java.io.PrintWriter;
import java.util.ArrayList;

import gov.nih.nlm.mor.db.row.Term2TermRow;
import gov.nih.nlm.mor.db.rxnorm.TermRelationship;

public class Term2TermTable {

	private ArrayList<TermRelationship> rows = new ArrayList<TermRelationship>();
	
	public Term2TermTable() {

	}
	
	public void add(TermRelationship r) {
		this.rows.add(r);
	}
	
	public void print(PrintWriter pw) {
		
	}
	
}
