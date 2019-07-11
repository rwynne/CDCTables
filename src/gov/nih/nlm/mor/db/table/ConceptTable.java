package gov.nih.nlm.mor.db.table;

import java.io.PrintWriter;
import java.util.ArrayList;

import org.json.JSONObject;

import gov.nih.nlm.mor.db.rxnorm.Concept;

public class ConceptTable {

	private ArrayList<Concept> rows = new ArrayList<Concept>();
	
	public ConceptTable() {
		
	}
	
	public void add(Concept c) {
		rows.add(c);
	}
	
	public boolean hasConcept(String s, String source) {
		boolean exists = false;
		for(Concept c : rows ) {
			if( c.getSourceId().equals(s) && c.getSource().equals(source) ) {
				exists = true;
				break;
			}
		}
		return exists;
	}
	
	public void print(PrintWriter pw) {
		/*	[DrugConceptID] [bigint] IDENTITY(1,1) NOT NULL,
	[PreferredTermID] [bigint] NOT NULL,
	[DrugAuthoritativeSourceID] [smallint] NOT NULL,
	[DrugConceptTypeID] [bigint] NULL,
	[DrugSourceConceptID] [varchar](32) NULL,
	[CreationDate] [smalldatetime] NULL,
	[CreationUserID] [char](4) NULL,
	[UpdatedDate] [smalldatetime] NULL,
	[UpdateUserID] [char](4) NULL,
	[IsActive] [bit] NOT NULL,
		 * 
		 */
		
		for( Concept c : rows ) {
			pw.println(c.getConceptId() + "|" + c.getPreferredTermId() + "|" + c.getSource() + "|" +
					c.getClassType() + "|" + c.getSourceId() + "||||||");
			pw.flush();
		}
		
	}	

}
