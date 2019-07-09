package gov.nih.nlm.mor.db.table;

import java.io.PrintWriter;
import java.util.ArrayList;

import gov.nih.nlm.mor.db.row.AuthoritativeSourceRow;

public class AuthoritativeSourceTable {
	private int primarykey = -1;
	private int codegenerator = 1;
	private ArrayList<AuthoritativeSourceRow> authoritativeSourceRows = new ArrayList<AuthoritativeSourceRow>();
	
	public AuthoritativeSourceTable() {
		
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
	public ArrayList<AuthoritativeSourceRow> getAuthoritativeSourceRows() {
		return authoritativeSourceRows;
	}
	public void setAuthoritativeSourceRows(ArrayList<AuthoritativeSourceRow> authoritativeSourceRows) {
		this.authoritativeSourceRows = authoritativeSourceRows;
	}
	

}
