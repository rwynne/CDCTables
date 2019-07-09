package gov.nih.nlm.mor.db;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.net.URL;
import java.util.ArrayList;
import java.util.HashMap;

import javax.net.ssl.HttpsURLConnection;

import org.json.JSONArray;
import org.json.JSONObject;

import gov.nih.nlm.mor.db.row.ConceptRow;
import gov.nih.nlm.mor.db.row.TermRow;
import gov.nih.nlm.mor.db.rxnorm.Concept;
import gov.nih.nlm.mor.db.rxnorm.ConceptRelationship;
import gov.nih.nlm.mor.db.rxnorm.Term;
import gov.nih.nlm.mor.db.rxnorm.TermRelationship;
import gov.nih.nlm.mor.db.table.AuthoritativeSourceTable;
import gov.nih.nlm.mor.db.table.Concept2ConceptTable;
import gov.nih.nlm.mor.db.table.ConceptTable;
import gov.nih.nlm.mor.db.table.ConceptTypeTable;
import gov.nih.nlm.mor.db.table.Term2TermTable;
import gov.nih.nlm.mor.db.table.TermTable;
import gov.nih.nlm.mor.db.table.TermTypeTable;

public class CDCTables {
	
	public AuthoritativeSourceTable authoritatveSourceTable = null;
	public Concept2ConceptTable concept2ConceptTable = null;
	public ConceptTable conceptTable = null;
	public ConceptTypeTable conceptTypeTable = null;
	public Term2TermTable term2TermTable = null;
	public TermTable termTable = null;
	public TermTypeTable termTypeTable = null;
	
	private PrintWriter authoritativeSourceFile = null;
	private PrintWriter conceptTypeFile = null;
	private PrintWriter termTypeFile = null;
	private PrintWriter termFile = null;
	private PrintWriter conceptFile = null;
	private PrintWriter term2termFile = null;
	private PrintWriter concept2conceptFile = null;
	
	private final String baseUrl = "https://rxnav.nlm.nih.gov/REST";
	private final String sourcesUrl = "";
	private final String brandNameUrl = "/allconcepts.json?tty=IN+PIN+BN";
	private final String synonymsUrlBegin = baseUrl + "/rxcui";
	private final String synonymsUrlEnd = "/related?tty=SY";
	private final String typesUrl = baseUrl + "";
	private final String drugConceptUrl = "";
	private final String allConceptsUrl = "https://rxnav.nlm.nih.gov/REST/allconcepts.json?tty=IN";
	
	private HashMap<Concept, Integer> class2Id = new HashMap<Concept, Integer>();
	
	private Integer codeGenerator = 1;
//more?
	
	public static void main(String[] args) {
		CDCTables tables = new CDCTables();
		tables.configure();
		tables.gather();
		tables.run();
		tables.cleanup();
	}
	
	private void configure() {
		//We are going to hardcode these filenames to ensure
		//deliverable consistency to CDC
		String authoritativePath = "./authoritative-source.txt";
		String conceptTypePath = "./concept-type.txt";
		String termTypePath = "./term-type.txt";
		String termPath = "./term.txt";
		String conceptPath = "./concept.txt";
		String term2termPath = "./term-term.txt";
		String concept2conceptPath = "./concept-concept";
		
		try {
			authoritativeSourceFile = new PrintWriter(new File(authoritativePath));
			conceptTypeFile = new PrintWriter(new File(conceptTypePath));
			termTypeFile = new PrintWriter(new File(termTypePath));
			termFile = new PrintWriter(new File(termPath));
			conceptFile = new PrintWriter(new File(conceptPath));
			term2termFile = new PrintWriter(new File(term2termPath));
			concept2conceptFile = new PrintWriter(new File(concept2conceptPath));
		}
		catch(Exception e) {
			System.out.print("There was an error trying to create one of the table files.");
			e.printStackTrace();
		}		
				
	}
	
	private void gather() {
		JSONObject allConcepts = null;
		ArrayList<String> rxCuis = new ArrayList<String>();
		
		try {
			allConcepts = getresult(allConceptsUrl);
		} catch (IOException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		
		AuthoritativeSourceTable authoritativeSourceTable = new AuthoritativeSourceTable();
		Concept2ConceptTable concept2ConceptTable = new Concept2ConceptTable();
		ConceptTable conceptTable = new ConceptTable();
		ConceptTypeTable conceptTypeTable = new ConceptTypeTable();
		Term2TermTable term2TermTable = new Term2TermTable();
		TermTable termTable = new TermTable();
		TermTypeTable termTypeTable = new TermTypeTable();
		
		if( allConcepts != null ) {
			JSONObject group = null;
			JSONArray minConceptArray = null;		
			
			group = (JSONObject) allConcepts.get("minConceptGroup");
			minConceptArray = (JSONArray) group.get("minConcept");
			for(int i = 0; i < minConceptArray.length(); i++ ) {
//				HashMap<Concept, ArrayList<Term>> concept2Terms = new HashMap<Concept, ArrayList<Term>>();
				Concept concept = new Concept();
				Term term = new Term();
				
				JSONObject minConcept = (JSONObject) minConceptArray.get(i);
				
				String rxcui = minConcept.get("rxcui").toString();
				String name = minConcept.get("name").toString();
				String type = minConcept.get("tty").toString();
				
				concept.setConceptId(++codeGenerator);
				concept.setSource("RxNorm");
				concept.setSourceId(rxcui);
				concept.setClassType("Drug");
				
				Integer conceptId = codeGenerator;
				
				term.setId(++codeGenerator);
				Integer preferredTermId = codeGenerator;
				
				concept.setPreferredTermId(preferredTermId);
				
				conceptTable.add(concept);
				
				term.setName(name);
				term.setTty("PV"); //this could be IN instead
				term.setSourceId(rxcui);
				term.setSource("RxNorm");
				
				termTable.add(term);
				
			
				JSONObject allProperties = null;
				JSONObject allRelated = null;
				JSONObject allClasses = null;
				
				try {
					allRelated = getresult("https://rxnav.nlm.nih.gov/REST/rxcui/" + rxcui + "/allrelated.json");
					allProperties = getresult("https://rxnav.nlm.nih.gov/REST/rxcui/" + rxcui + "/allProperties.json?prop=all");
					allClasses = getresult("https://rxnav.nlm.nih.gov/REST/rxclass/class/byRxcui.json?rxcui=" + rxcui + "&relaSource=ATC"); //update for other sources?
				} catch(IOException e) {
					e.printStackTrace();
				}
				
				if( allRelated != null ) {
					JSONObject allRelatedGroup = (JSONObject) allRelated.get("allRelatedGroup");
					JSONArray conceptGroup = (JSONArray) allRelatedGroup.get("conceptGroup");
					
					for( int j = 0; j < conceptGroup.length(); j++ ) {
						
						JSONObject relatedConcept = (JSONObject) conceptGroup.get(j);
						String relatedType = relatedConcept.get("tty").toString();
						
						if( relatedType.equals("PIN") || relatedType.equals("BN") ) {
							JSONObject relatedProperties = (JSONObject) relatedConcept.get("conceptProperties");
							if( relatedProperties != null ) {
								Term relatedTerm = new Term();
								
								String relatedCuiString = relatedProperties.get("rxcui").toString();
								String relatedName = relatedProperties.get("name").toString();
								
								term.setId(++codeGenerator);
								term.setName(relatedName);
								term.setTty(relatedType);
								term.setSourceId(relatedCuiString);
								term.setSource("RxNorm");
								
								termTable.add(term);
								
								Integer termId = codeGenerator;
								
								TermRelationship termRel = new TermRelationship();
								termRel.setId(++codeGenerator);
								termRel.setTermId1(termId);
								termRel.setTermId2(preferredTermId);
								termRel.setRelationship(relatedType);
								
								term2TermTable.add(termRel);
								
							}
							
						}
						
					}
				}
				
				//what are we looking for here?  Just UNII it seems
				//so far
				if( allProperties != null ) {
					JSONObject propConceptGroup = (JSONObject) allProperties.get("propConceptGroup");
					JSONArray propConcept = (JSONArray) propConceptGroup.get("propConcept");
					
					for( int j = 0; j < propConcept.length(); j++ ) {
						
						JSONObject prop = (JSONObject) propConcept.get(j);
						String propName = prop.getString("propName");
						if( propName.equals("RxNorm Synonym") ) {
							Term synonym = new Term();
							synonym.setId(++codeGenerator);					
							synonym.setName(prop.get("propValue").toString());
							synonym.setTty("SY");
							synonym.setSourceId(rxcui);
							synonym.setSource("RxNorm");
							
							termTable.add(synonym);
							
							Integer synonymId = codeGenerator;							
							
							TermRelationship termRel = new TermRelationship();
							termRel.setId(++codeGenerator);
							termRel.setTermId1(synonymId);							
							termRel.setTermId2(preferredTermId);
							termRel.setRelationship("SY");
							
							term2TermTable.add(termRel);
							
						}
//						else if( propName.equals("UNII_CODE") ) {
//							Term uniiCode = new Term();
//							uniiCode.setId(++codeGenerator);
//							uniiCode.setName(prop.getString("propValue").toString());
//							uniiCode.setTty("UNII_CODE");
//							
//							
//						}							
					}
					
				}
				
				if( allClasses != null ) {
					if( !allClasses.isNull("rxclassDrugInfoList") ) {
						JSONArray drugInfoList = (JSONArray) allClasses.get("rxclassDrugInfoList");
						
						for( int j=0; j < drugInfoList.length(); j++ ) {
							JSONObject rxclassDrugInfo = (JSONObject) drugInfoList.get(j);
							if( !rxclassDrugInfo.isNull("rxclassMinConceptItem") ) {
								JSONObject rxclassMinConceptItem = (JSONObject) rxclassDrugInfo.get("rxclassMinConceptItem");
								Concept sourceConcept = new Concept();
								Term sourceTerm = new Term();
								
								sourceTerm.setId(++codeGenerator);
								Integer sourceTermId = codeGenerator;
								sourceTerm.setName(rxclassMinConceptItem.get("className").toString());
								sourceTerm.setSourceId(rxclassMinConceptItem.get("classId").toString());
								sourceTerm.setTty("");
								sourceTerm.setSource("ATC");
								
								termTable.add(sourceTerm);
								
								sourceConcept.setConceptId(++codeGenerator);
								sourceConcept.setPreferredTermId(sourceTermId);
								sourceConcept.setSource("ATC");
								sourceConcept.setSourceId(rxclassMinConceptItem.get("classId").toString());
								sourceConcept.setClassType("Class");
								
								conceptTable.add(sourceConcept);
								
								
							}
							
						}
						
					}
					
				}
				
				
			}
			
			
			
		}
		
		
	}
	
	private void run() {
		nlmDrugAuthoritativeSource();
		nlmDrugConceptType();
		nlmDrugTermType();
		nlmDrugTerm();
		nlmDrugConcept();
		nlmDrugTerm2Term();
		nlmConcept2Concept();
	}
	
	private void cleanup() {
		authoritativeSourceFile.close();
		conceptTypeFile.close();
		termTypeFile.close();
		termFile.close();
		conceptFile.close();
		term2termFile.close();
		concept2conceptFile.close();
	}
	
	private void nlmDrugAuthoritativeSource() {
		
		
	}
	
	private void nlmDrugConceptType() {
		
	}
	
	private void nlmDrugTermType() {
		
	}
	
	private void nlmDrugTerm() {
		
	}
	
	private void nlmDrugConcept() {
		
	}
	
	private void nlmDrugTerm2Term() {
		
	}

	private void nlmConcept2Concept() {
		
	}
	
	public static JSONObject getresult(String URLtoRead) throws IOException {
		URL url;
		HttpsURLConnection connexion;
		BufferedReader reader;
		
		String line;
		String result="";
		url= new URL(URLtoRead);
	
		connexion= (HttpsURLConnection) url.openConnection();
		connexion.setRequestMethod("GET");
		reader= new BufferedReader(new InputStreamReader(connexion.getInputStream()));	
		while ((line =reader.readLine())!=null) {
			result += line;
			
		}
		
		JSONObject json = new JSONObject(result);
		return json;
	}	

}
