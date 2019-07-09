package gov.nih.nlm.mor.db.row;

import org.json.JSONObject;

public class ConceptTypeRow {
	private int primarykey = -1;
	private int codegenerator = 1;
	
	public ConceptTypeRow(JSONObject j) {
		
	}
	
	public ConceptTypeRow() {
		
	}
	
	private String getRowString() {
		String row = "";
		
		return row;
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

}
