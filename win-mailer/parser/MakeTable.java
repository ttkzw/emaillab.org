import java.io.File;
import java.io.FileWriter;
import java.io.PrintWriter;
import java.io.BufferedWriter;
import java.io.FileReader;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.Hashtable;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.DocumentBuilder;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;

public class MakeTable
{
    Document[] doc;
    DocumentBuilder docBuilder;
    int nFiles;
    String[] filename;

    private static String XMLINPUTDIR = "/home/taki/myweb/win-mailer/data/tmp";
    private static String HTMLOUTPUTDIR = "/home/taki/myweb/win-mailer";
    private static String HTMLTEMPLATEDIR = 
	"/home/taki/myweb/win-mailer/template";
    private static String[] FILE =
    {
	"table-basic.html",
	"table-header.html",
	"table-japanese.html",
	"table-lang.html",
	"table-cipher.html",
	"table-otherspec.html"
    };

    private static String FOOT = "</table>\n</body>\n</html>\n";

    public MakeTable() {
	init();
	filename = getFilenameList(XMLINPUTDIR);
	nFiles = filename.length;
	doc = new Document[nFiles];
	for ( int i = 0; i < nFiles; i++) {
	    doc[i] = this.parse(XMLINPUTDIR + File.separator + filename[i]);
	}
	makehtml();
    }

    public void init() {
	try {
	    DocumentBuilderFactory docBuilderFactory = 
		DocumentBuilderFactory.newInstance();
	    docBuilderFactory.setValidating(false);
	    docBuilder = docBuilderFactory.newDocumentBuilder();
	} catch (Throwable t) {
	    t.printStackTrace ();
	}

    }

    private String[] getFilenameList(String dir) {
	String[] filename = null;
	try {
	    File f = new File(dir);
	    filename = f.list();
	} catch (Exception e) {
	    System.err.println(e);
	}
	if (filename == null) {
	    System.err.println("Error: cannot read " + dir);
	    System.exit(1);
	}
	return filename;
    }

    private Document parse(String filepath) {
	Document doc = null;
	try {
	    doc = docBuilder.parse (new File (filepath));
	    doc.getDocumentElement ().normalize ();
	} catch (SAXParseException err) {
	    System.out.println ("** Parsing error" 
		+ ", line " + err.getLineNumber ()
		+ ", uri " + err.getSystemId ());
	    System.out.println("   " + err.getMessage ());
	    // print stack trace as below

	} catch (SAXException e) {
	    Exception	x = e.getException ();
	    ((x == null) ? e : x).printStackTrace ();
	} catch (Throwable t) {
	    t.printStackTrace ();
	}
	return doc;
    }

    private void makehtml() {
	Node node;
	String nodeName;

	Hashtable[] basicInformation = new Hashtable[nFiles];
	String[] muaname = new String[nFiles];
	String[] tableBasic = new String[nFiles];
	String[] tableHeader = new String[nFiles];
	String[] tableJapanese = new String[nFiles];
	String[] tableLang = new String[nFiles];
	String[] tableCipher = new String[nFiles];
	String[] tableOtherSpec = new String[nFiles];
	
	for ( int i = 0; i < nFiles; i++) {
	    String head = "";
	    Element rootElement = doc[i].getDocumentElement();
	    rootElement.normalize();
	    muaname[i] = rootElement.getAttribute("name");
	    NodeList nodes = rootElement.getChildNodes();
	    int nNodes = nodes.getLength();
	    for ( int j = 0; j < nNodes; j++) {
		node = nodes.item(j);
		nodeName = node.getNodeName();
		if(nodeName.equals("basic-information")) {
		    basicInformation[i] = getHashtable(node);
		    String dist = 
			(String) basicInformation[i].get("distribution");
		    head = "<tr id=\"" + filename[i] + "\" class=\""
			+ dist + "\"><th>" + muaname[i] + "</th>";
		    tableBasic[i] = getTableBasic(basicInformation[i], head);
		} else if(nodeName.equals("header")) {
		    tableHeader[i] = getTableHeader(node, head);
		} else if(nodeName.equals("japanese")) {
		    tableJapanese[i] = getTableJapanese(node, head);
		} else if(nodeName.equals("language")) {
		    tableLang[i] = getTableLang(node, head);
		} else if(nodeName.equals("cipher")) {
		    tableCipher[i] = getTableCipher(node, head);
		} else if(nodeName.equals("other-specifications")) {
		    tableOtherSpec[i] = getTableOtherSpec(node, head);
		}
	    }
	}

	try {
	    writeHTML(0,tableBasic);
	    writeHTML(1,tableHeader);
	    writeHTML(2,tableJapanese);
	    writeHTML(3,tableLang);
	    writeHTML(4,tableCipher);
	    writeHTML(5,tableOtherSpec);
	} catch (IOException e) {
	    System.err.println(e);
	    System.exit(1);
	}
    }

    private Hashtable getHashtable(Node node) {
	Hashtable hashtable = new Hashtable();
	String nodeName;
	String nodeValue;

	NodeList nodes = node.getChildNodes();
	int nNodes = nodes.getLength();
	for ( int i = 0; i < nNodes; i++) {
	    Node child = nodes.item(i);
	    if ( child.getNodeType() == Node.ELEMENT_NODE) {
		nodeName = child.getNodeName();
		if (child.hasChildNodes()) {
		    nodeValue = child.getFirstChild().getNodeValue();
		} else {
		    nodeValue = "";
		}
		hashtable.put(nodeName, nodeValue);
		NodeList grandchildren = child.getChildNodes();
		for ( int j = 0; j < grandchildren.getLength(); j++) {
		    Node grandchild = grandchildren.item(j);
		    if ( grandchild.getNodeType() == Node.ELEMENT_NODE) {
			if (grandchild.hasChildNodes()) {
			    nodeValue = grandchild.getFirstChild()
				.getNodeValue();
			} else {
			    nodeValue = "";
			}
			hashtable.put(nodeName + " " + 
				      grandchild.getNodeName(), nodeValue);
		    }
		}
	    }
	}
	return hashtable;
    }


    private String getTableBasic(Hashtable hashtable, String head) {
	StringBuffer buffer = new StringBuffer();
	String value;

	buffer.append(head);
	buffer.append("<td>" + (String) hashtable.get("name"));
	buffer.append("</td><td>" + (String) hashtable.get("version"));
	buffer.append("</td><td>" + (String) hashtable.get("release month")
		      + "/" + (String) hashtable.get("release year"));
	buffer.append("</td><td><a href=\"" + (String) hashtable.get("uri")
		      + "\">" + (String) hashtable.get("person-company")
		      + "</a>");
	buffer.append("</td><td>" + (String) hashtable.get("distribution"));
	value = (String) hashtable.get("price");
	buffer.append("</td><td>" + returnYesNo(value));
	buffer.append("</td></tr>\n");

	return buffer.toString();
    }

    private String getTableHeader(Node node, String head) {
	String value;
	StringBuffer buffer = new StringBuffer();

	Hashtable hashtable = getHashtable(node);

	buffer.append(head);
	buffer.append("<td>");
	value = (String) hashtable.get("message-id is-generated");
	if (value.equals("yes")) {
	    if (String.valueOf(hashtable.get("message-id uniqueness"))
		.equals("high")) buffer.append("¡û");
	    else buffer.append("¢¤");
	} else if (value.equals("no")) buffer.append("¡ß");
	else buffer.append("-");

	value = (String) hashtable.get("date is-generated");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("in-reply-to is-generated");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("references is-generated");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("content-disposition is-generated");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("mediatype suitable-mediatype");
	buffer.append("</td><td>" + returnYesNo(value));

	/*	
	value = (String) hashtable.get("mediatype mediatype-parameter");
	if (! value.equals("")) buffer.append("(" + value + ")");
	*/
	buffer.append("</td></tr>\n");

	return buffer.toString();
    }

    private String getTableJapanese(Node node, String head) {
	String value;
	StringBuffer buffer = new StringBuffer();

	Hashtable hashtable = getHashtable(node);

	buffer.append(head);

	value = (String) hashtable.get("jisx0201kana");
	buffer.append("<td>" + returnYesNo(value));

	value = (String) hashtable.get("os-dependent-char");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("filename-encoding");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("rfc2231-decoding");
	buffer.append("</td><td>" + returnYesNo(value));

	buffer.append("</td></tr>\n");

	return buffer.toString();
    }

    private String getTableLang(Node node, String head) {
	String value;
	StringBuffer buffer = new StringBuffer();

	Hashtable hashtable = getHashtable(node);

	buffer.append(head);

	value = (String) hashtable.get("latin1");
	buffer.append("<td>" + returnYesNo(value));

	value = (String) hashtable.get("latin2");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("turkish");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("nordic");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("cyrillic");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("arabic");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("greek");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("hebrew");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("japanese");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("chinese");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("chinese-tw");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("korean");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("utf-8");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("utf-7");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("note");
	buffer.append("</td><td>" + returnYesNo(value));

	buffer.append("</td></tr>\n");

	return buffer.toString();
    }

    private String getTableCipher(Node node, String head) {
	String value;
	StringBuffer buffer = new StringBuffer();

	Hashtable hashtable = getHashtable(node);

	buffer.append(head);

	value = (String) hashtable.get("pgp pgp-version");
	if (value.equals("2.6")) value = "";
	buffer.append("<td>" + returnYesNo(value));

	value = (String) hashtable.get("pgp pgp-mime");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("smime is-implemented");
	buffer.append("</td><td>" + returnYesNo(value));
	
	value = (String) hashtable.get("tls smtp");
	buffer.append("</td><td>" + returnYesNo(value));
	
	value = (String) hashtable.get("tls pop");
	buffer.append("</td><td>" + returnYesNo(value));
	
	value = (String) hashtable.get("tls imap");
	buffer.append("</td><td>" + returnYesNo(value));
	
	buffer.append("</td></tr>\n");

	return buffer.toString();
    }

    private String getTableOtherSpec(Node node, String head) {
	String value;
	StringBuffer buffer = new StringBuffer();

	Hashtable hashtable = getHashtable(node);

	buffer.append(head);

	value = (String) hashtable.get("smtp is-implemented");
	buffer.append("<td>" + returnYesNo(value));

	value = (String) hashtable.get("smtp pop-before-smtp");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("smtp authentication");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("pop is-implemented");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("pop authentication");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("imap is-implemented");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("imap authentication");
	buffer.append("</td><td>" + returnYesNo(value));

	value = (String) hashtable.get("ldap is-implemented");
	buffer.append("</td><td>" + returnYesNo(value));
	
	value = (String) hashtable.get("ldap jp-char");
	if (value.equals("yes")) buffer.append("(ja)");
	
	buffer.append("</td></tr>\n");

	return buffer.toString();
    }

    private void writeHTML(int number, String[] table) throws IOException {
	String path;
	String line;
	StringBuffer buffer = new StringBuffer();

	path = HTMLTEMPLATEDIR  + File.separator + FILE[number];
	BufferedReader in =
	    new BufferedReader(new FileReader(path));
	while( (line = in.readLine()) != null) {
	    buffer.append(line + "\n");
	}

	path = HTMLOUTPUTDIR + File.separator + FILE[number];
	PrintWriter out = 
	    new PrintWriter(new BufferedWriter(new FileWriter(path)));
	out.write(buffer.toString());
	for ( int i = 0; i < nFiles; i++)
	    out.write(table[i]);
	out.write(FOOT);
	out.flush();
	out.close();
	out = null;
    }

    private String returnYesNo(String value) {
	String result = "";
	if (value.startsWith("yes"))
	    result = "¡û" + value.substring(3);
	else if (value.startsWith("incomplete"))
	    result = "¢¤" + value.substring(10);
	else if (value.startsWith("no"))
	    result = "¡ß" + value.substring(2);
	else if (value.equals("")) result = "-";
	else result = value;
	return result;
    }

    public static void main (String argv []) {
	MakeTable makeTable = new MakeTable();

	System.exit (0);
    }

}
