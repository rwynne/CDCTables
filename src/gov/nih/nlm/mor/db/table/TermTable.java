package gov.nih.nlm.mor.db.table;

import java.io.PrintWriter;
import java.util.ArrayList;

import gov.nih.nlm.mor.db.row.TermRow;
import gov.nih.nlm.mor.db.rxnorm.Term;

public class TermTable {
	private ArrayList<Term> rows = new ArrayList<Term>();
	
	public TermTable() {
		
	}
	
	public void add(Term t) {
		rows.add(t);
	}
	
	public void print(PrintWriter pw) {
		
	}

}
