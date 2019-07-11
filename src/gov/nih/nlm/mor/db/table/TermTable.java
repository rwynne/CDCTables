package gov.nih.nlm.mor.db.table;

import java.io.PrintWriter;
import java.util.ArrayList;

import gov.nih.nlm.mor.db.rxnorm.Term;

public class TermTable {
	private ArrayList<Term> rows = new ArrayList<Term>();
	
	public TermTable() {
		
	}
	
	public void add(Term t) {
		rows.add(t);
	}
	
	public void print(PrintWriter pw) {
		/*	[DrugTermID] [bigint] IDENTITY(1,1) NOT NULL,
	[DrugTermName] [varchar](50) NOT NULL,
	[DrugTTYID] [smallint] NOT NULL,
	[DrugExternalID] [varchar](32) NULL,
	[DrugAuthoritativeSourceID] [smallint] NULL,
	[CreationUserID] [char](4) NULL,
	[CreationDate] [smalldatetime] NULL,
	[UpdatedUserID] [char](5) NULL,
	[UpdatedDate] [smalldatetime] NULL,
	[IsActive] [bit] NULL,
		 * 
		 */
		
		for( Term t : rows ) {
			pw.println(t.getId() + "|" + t.getName() + "|" + t.getTty() + 
					"|" + t.getSourceId() + "|" + t.getSource() + "|||||");
			pw.flush();
		}
		
	}

}
