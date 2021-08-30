import java.io.BufferedReader;
import java.io.*;
import java.nio.charset.StandardCharsets;
import java.util.*;



public class Parse {

    private static int counter = 0;

    public static List<String[]> readDataSet() throws IOException {
        List<String[]> dataset = new ArrayList<>();

        String pathToCsv = "C:/Users/Rita/Desktop/2ºSemestre/SRCR/Trabalho Prático/TP-INDIVIDUAL/dataset.csv";
        BufferedReader csvReader = new BufferedReader(new InputStreamReader(
                new FileInputStream(pathToCsv), StandardCharsets.UTF_8));
        String row;
        csvReader.readLine();

        while ((row = csvReader.readLine()) != null) {
            String[] data = row.split(";");
            dataset.add(data);
        }
        csvReader.close();

        return dataset; 
    }

    public static List<String> parseFirstDataSet(List<String[]> dataset) throws IOException { 

        //Latitude, Longitude, Ponto de Recolha, [ObjectID], Tipo, Total Litros

        List<String> res = new ArrayList<>();

        String fstLine = "Latitude;Longitude;IDObjeto;Freguesia_PRecolha;ID_PRecolha;Nome_Rua;Rua_Adj;Tipo_Residuo;Tipo_Contentor;Capacidade_Contentor;QT_Contentor;Total_Qt_Litros\n";
        res.add(fstLine);

        for(String[] lst : dataset) { 

            String [] ponto_recolha = lst[4].split(":");

            if (ponto_recolha.length == 3) {
                String [] rua_lst = ponto_recolha[1].split("\\(" );
                String [] adjacente_lst = ponto_recolha[2].split("-");
                String idRua = ponto_recolha[0];
                String rua = rua_lst[0];
                String adjacente = adjacente_lst[0]; 

                StringBuilder sb = new StringBuilder();

                for(int i = 0; i < lst.length; i++) {
                    if (i == 4) {
                        sb.append(idRua);     sb.append(";");
                        sb.append(rua);       sb.append(";");
                        sb.append(adjacente); sb.append(";");
                    } else {
                        sb.append(lst[i]);
                        sb.append(";");
                    }
                }

                String line = sb.toString();
                res.add(line);

            } else if (ponto_recolha.length == 2) {
                String [] rua_lst = ponto_recolha[1].split("," );
                String idRua = ponto_recolha[0];
                String rua = rua_lst[0];

                StringBuilder sb = new StringBuilder();

                for(int i = 0; i < lst.length; i++) {
                    if (i == 4) {
                        sb.append(idRua);     sb.append(";");
                        sb.append(rua);       sb.append(";");
                        sb.append("final");   sb.append(";"); 
                    } else {
                        sb.append(lst[i]);
                        sb.append(";");
                    }
                }

                String line = sb.toString();
                res.add(line);
            }

        }

        return res;
    }



    public static List<String> parseDataSet(List<String> dataset) throws IOException { 

        dataset.remove(0);


        HashMap<Map.Entry<Integer,String>,Map.Entry<Integer,String>> adjacentes = new HashMap<>();
        for(int i = 0; i < dataset.size(); i++) {
            String [] line = dataset.get(i).split(";");
            String rua = line[5];
            String [] nextLine = null;
            if(i != dataset.size()-1) nextLine = dataset.get(i+1).split(";");

            if(nextLine != null) {
                if(nextLine[4].compareTo(line[4]) != 0 || nextLine[7].compareTo(line[7]) != 0) { 
                    Map.Entry<Integer,String> ruaPrincipal = new AbstractMap.SimpleEntry<>(Integer.parseInt(line[4]),line[7]);
                    Map.Entry<Integer,String> ruaAbaixo = new AbstractMap.SimpleEntry<>(Integer.parseInt(nextLine[4]),nextLine[7]);

                    adjacentes.put(ruaPrincipal,ruaAbaixo);

                }
            }

        }


        //Latitude, Longitude, Ponto de Recolha, [ObjectID], Tipo, Total Litros

        List<String> res = new ArrayList<>();


        Map<Map.Entry<Integer,String>,Linha> parse = new HashMap<>();

        for(String s : dataset) { 
            String [] s_campos = s.split(";");

            Map.Entry<Integer,String> key = new AbstractMap.SimpleEntry<>(Integer.parseInt(s_campos[4]),s_campos[7]); 

            if (parse.containsKey(key)) { 
                Linha info = parse.get(key); 

                info.addQtContentor(Integer.parseInt(s_campos[11])); 
                info.addObject(Integer.parseInt(s_campos[2]));
                info.setRua(s_campos[5]); 
                info.setRuaAdj(s_campos[6]);

                parse.put(key,info);

            } else {

                counter++;

                Linha info = new Linha();

                info.setID(counter);

                s_campos[0] = s_campos[0].replace(",",".");
                s_campos[1] = s_campos[1].replace(",",".");

                info.setLatitude(Float.parseFloat(s_campos[0]));
                info.setLongitude(Float.parseFloat(s_campos[1]));
                info.addQtContentor(Integer.parseInt(s_campos[11]));
                info.addObject(Integer.parseInt(s_campos[2]));
                info.setRua(s_campos[5]);
                info.setRuaAdj(s_campos[6]);

                parse.put(key, info);

            }

        }

        for(Map.Entry<Integer,String> e : parse.keySet()) {

            Linha info = parse.get(e); 

            String rua = info.getRua(); 
            String ruaAdj = info.getRuaAdj().replace(" ","");

            Map.Entry<Integer,String> adjacenteBaixo = adjacentes.get(e); 

            if (adjacenteBaixo != null) { 
                Linha adjBaixo = parse.get(adjacenteBaixo);

                info.addAdjacente(adjBaixo.getID());
            }

            for(Map.Entry<Integer,String> entry : parse.keySet()) { 
                Linha linha = parse.get(entry);
                String rua_replace = linha.getRua().replace(" ",""); 

                if (rua_replace.compareTo(ruaAdj) == 0) {
                    int id = linha.getID();
                    info.addAdjacente(id);
                }
            }

            parse.put(e,info); 

        }


        System.out.println("Nr linhas: " + parse.size());
        for(Map.Entry<Integer,String> e : parse.keySet()) {
            Linha p = parse.get(e);

            System.out.println(e.getKey() + " " + e.getValue() + " " + p.toString());
        }


        File file = new File("base_conhecimento.pl");
        OutputStreamWriter writer = new OutputStreamWriter(new FileOutputStream(file), StandardCharsets.UTF_8 );

        for(Map.Entry<Integer,String> e : parse.keySet()) { 
            Linha p = parse.get(e);

            StringBuilder sb = new StringBuilder();

            sb.append("registo(");
            sb.append(e.getKey());
            sb.append(",");
            sb.append('"');
            sb.append(e.getValue().toLowerCase());
            sb.append('"');
            sb.append(",");
            sb.append(p.convertToBC());

            writer.write(sb.toString());

            System.out.println(e.getKey() + " " + e.getValue() + " " + p.toString());
        }

        System.out.println("done!");
        writer.close();

        return res;

    }

    public static void main(String [] args) throws IOException {

        List<String[]> dataset = readDataSet();

        List<String> res = parseFirstDataSet(dataset);

        parseDataSet(res);

    }

    static class Linha {
        private int id;
        private String rua;
        private String ruaAdj;
        private float latitude;
        private float longitude;
        private Set<Integer> objectID; 
        private Set<Integer> idsAdjacentes; 
        private int totalLitros;

        public Linha() {
            latitude = 0;
            longitude = 0;
            objectID = new TreeSet<>();
            idsAdjacentes = new TreeSet<>();
            totalLitros = 0;
        }

        public Linha(String rua, String ruaAdj, float latitude, float longitude, Set<Integer> objectID, Set<Integer> idsAdjacentes, int totalLitros) {
            this.rua = rua;
            this.ruaAdj = ruaAdj;
            this.latitude = latitude;
            this.longitude = longitude;
            this.objectID = objectID;
            this.idsAdjacentes = idsAdjacentes;
            this.totalLitros = totalLitros;
        }

        public void setID(int id) {
            this.id = id;
        }

        public int getID() {
            return this.id;
        }

        public void addQtContentor(int qt) {
            this.totalLitros += qt;
        }

        public void addObject(int object) {
            this.objectID.add(object);
        }

        public void addAdjacente(int adj) {
            this.idsAdjacentes.add(adj);
        }

        public void setRuaAdj(String ruaAdj) {
            this.ruaAdj = ruaAdj;
        }

        public String getRuaAdj() {
            return ruaAdj;
        }

        public String getRua() {
            return rua;
        }

        public void setRua(String rua) {
            this.rua = rua;
        }

        public void setLatitude(float latitude) {
            this.latitude = latitude;
        }

        public void setLongitude(float longitude) {
            this.longitude = longitude;
        }

        public String convertToBC() {
            return  id +
                    "," + latitude +
                    "," + longitude +
                    "," + objectID +
                    "," + idsAdjacentes +
                    "," + totalLitros +
                    ").\n";
        }

        @Override
        public String toString() {
            return "Linha{" +
                    "id=" + id +
                    ", rua='" + rua + '\'' +
                    ", ruaAdj='" + ruaAdj + '\'' +
                    ", latitude=" + latitude +
                    ", longitude=" + longitude +
                    ", objectID=" + objectID +
                    ", idsAdjacentes=" + idsAdjacentes +
                    ", totalLitros=" + totalLitros +
                    '}';
        }
    }

}

