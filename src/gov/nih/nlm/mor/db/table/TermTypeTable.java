package gov.nih.nlm.mor.db.table;

import java.io.PrintWriter;
import java.util.ArrayList;

import gov.nih.nlm.mor.db.row.TermTypeRow;

public class TermTypeTable {
	private int primarykey = -1;
	private int codegenerator = 1;
	private ArrayList<TermTypeRow> termTypeRows = new ArrayList<TermTypeRow>();
	
	
	public TermTypeTable() {
		
	}
	
	public void print(PrintWriter pw) {
		
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
	public ArrayList<TermTypeRow> getTermTypeRows() {
		return termTypeRows;
	}
	public void setTermTypeRows(ArrayList<TermTypeRow> termTypeRows) {
		this.termTypeRows = termTypeRows;
	}
	
}
