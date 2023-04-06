#include <iostream>
#include <sstream>
#include "TROOT.h"
#include "TFile.h"
#include "TList.h"
#include "TDirectory.h"
#include "TH1.h"
#include "TH2.h"
#include "TTree.h"
#include "TGraph.h"
#include "TSystem.h"
#include "TString.h"
#include "TMemFile.h"
#include "TSocket.h"
#include "TServerSocket.h"
#include "THttpServer.h"

#define PAWC_SIZE 32000000
extern "C" int pawc_[PAWC_SIZE];
extern "C" int quest_[100];
extern "C" int hcbits_[37];
extern "C" int hcbook_[51];
extern "C" int rzcl_[11];
extern "C" int zebq_[104];
extern "C" int mzcc_[411];
extern "C" int bidon_[10006];
extern "C" int mzcwk_[5120];
extern "C" int fzcx_[71];
extern "C" int fzci_[78];

extern "C" void  hlimit_(const int&);
extern "C" void  hrin_(const int&,const int&,const int&);
extern "C" void  hnoent_(const int&,const int&);
extern "C" void  hgive_(const int&,const char*,const int&,const float&,const float&,const int&,const float&,const float&,const int&,const int&,const int);
extern "C" void  hdelet_(const int&);
extern "C" float hi_(const int&,const int&);
extern "C" float hie_(const int&,const int&);
extern "C" float hif_(const int&,const int&);
extern "C" float hij_(const int&,const int&,const int&);
extern "C" float hije_(const int&,const int&,const int&);
extern "C" void  hcdir_(const char*,const char* ,const int,const int);
/* --> Nobu added */
extern "C" void  hlimap_(const int&,const char*, const int);
extern "C" void  hidall_(const int*, const int&);
extern "C" void  hdcofl_();
extern "C" void  hsifla_(const int&,const int&);
extern "C" void  hrdir_(const int&, char*,const int&,const int);

int hbk_id_title_flag = 2;
int shms2srv_sync_flag = 1;


void init_hbook(const int kind){
  static int kind_saved = -1;
  if (kind != kind_saved){
    if (kind == 0){
      int pawc_size = PAWC_SIZE;
      hlimit_(pawc_size);
    }
    kind_saved = kind;
  }
  return;
}

std::string get_shm_names_str(const char *shm_names){
  std::string shm_names_str = shm_names;
  while (((int)shm_names_str.find(",")) > -1) {
    shm_names_str[shm_names_str.find(",")] = ' ';
  }
  for (int i = 0; i < shm_names_str.length(); i++) {
    if((int)(shm_names_str[i]) >= 0x61 &&
       (int)(shm_names_str[i]) <= 0x7a){
      /* Lower case --> Upper case w/o <algorithm> header */
      shm_names_str[i] = (char)((int)shm_names_str[i] - 0x20);
    }
  }
  if (shm_names_str.length() == 0) {
    FILE* pipe = popen("ipcs -m", "r");
    char buffer[256];
    int macos_flag = 0;
    if (fgets(buffer, 256, pipe) != NULL) {
      std::string buffer_str = buffer;
      if (buffer_str.substr(0,3) == "IPC") {
	macos_flag = 1;
      }
    }
    int nline = 0;
    while (fgets(buffer, 256, pipe) != NULL) {
      nline++;
      if (nline <= 2) {
	continue;
      }
      std::stringstream ss(buffer);
      std::string buffer_str;
      if (macos_flag == 1){
	ss >> buffer_str;
	ss >> buffer_str;
	ss >> buffer_str;
      }else{
	ss >> buffer_str;
      }
      std::stringstream ss2;
      ss2 << std::hex << buffer_str;
      unsigned int str_int = 0;
      ss2 >> str_int;
      std::string out_str = "";
      if ((str_int&0x000000ff)>0) {out_str += (char)((str_int&0x000000ff)>>0);}
      if ((str_int&0x0000ff00)>0) {out_str += (char)((str_int&0x0000ff00)>>8);}
      if ((str_int&0x00ff0000)>0) {out_str += (char)((str_int&0x00ff0000)>>16);}
      if ((str_int&0xff000000)>0) {out_str += (char)((str_int&0xff000000)>>24);}
      if (out_str.length() == 0){
	continue;
      }
      ss >> buffer_str;
      ss >> buffer_str;
      int valid_name_flag = 1;
      for (int i = 0; i < out_str.length(); i++) {
	if((int)(out_str[i]) < 0x20 ||
	   (int)(out_str[i]) > 0x7e){
	  valid_name_flag = 0; 
	}
      }
      if (valid_name_flag == 0) {
	continue;
      }
      for (int i = 0; i < out_str.length(); i++) {
	if((int)(out_str[i]) >= 0x61 &&
	   (int)(out_str[i]) <= 0x7a){
	  out_str[i] = (char)((int)out_str[i] - 0x20);
	}
      }
      shm_names_str += out_str + "," + buffer_str + " ";
    }
    pclose(pipe);
  }
  return shm_names_str;
}

std::string open_input_shm(const char* shm_name){
  /* std::cout << "open_input_shm starts." << std::endl; */
  std::string shm_name_str = shm_name;
  shm_name_str = shm_name_str.substr(0,4);
  if (((int)shm_name_str.find(",")) > -1) {
    shm_name_str = shm_name_str.substr(0,shm_name_str.find(","));
  }
  if (shm_name_str.length()==0){
    return "";
  }
  for (int i = 0; i < shm_name_str.length(); i++) {
    if((int)(shm_name_str[i]) < 0x20 ||
	      (int)(shm_name_str[i]) > 0x7e){
      return "";
    }
  }
  for (int i = 0; i < shm_name_str.length(); i++) {
    if((int)(shm_name_str[i]) >= 0x61 &&
       (int)(shm_name_str[i]) <= 0x7a){
      shm_name_str[i] = (char)((int)shm_name_str[i] - 0x20);
    }
  }
  /*std::cout << "before hlimap in open_input_shm" << std::endl;*/
  hlimap_(0,shm_name_str.c_str(),shm_name_str.length());
  /*std::cout << "before hrin in open_input_shm" << std::endl;*/
  hdelet_(0);
  hrin_(0,9999,0);
  /*std::cout << "before hdelet in open_input_shm" << std::endl;*/
  hdelet_(0);
  if (quest_[0]) {
    printf("Error: cannot open the shared memory: %s\n",shm_name_str.c_str());
    return "";
  }
  shm_name_str = "//" + shm_name_str;
  return shm_name_str;
}

THttpServer* open_output_srv(int port) {
  static THttpServer* serv = 0;
  static int saved_port = 0;
  /* static int message_counter = 0; */
  if(port < 0){
    if(serv != 0){
      std::cout << "THttpServer on port " << saved_port << " was deleted." << std::endl;
      delete serv;
      serv = 0;
    }
    return 0;
  }
  saved_port = port;
  if (serv == 0) {
    std::cout << "Check if the port: " << port << " can be bound or not." << std::endl;
    TServerSocket *ssocket = new TServerSocket(port);
    if(!ssocket->IsValid()){
      std::cout << "TServerSocket::GetErrorCode(): " << ssocket->GetErrorCode() << std::endl;
      std::cout << "Probably port: " << port << " is already in use." << std::endl;
      std::cout << "Use a different port or wait a moment until the port becomes available." << std::endl;
      delete ssocket;
      return 0;
    }
    std::cout << "The port: " << port << " can be bound." << std::endl;
    /*
    std::cout << "Check if the port: " << port << " is open or not on the firewall of " << gSystem->HostName() <<"."<< std::endl;
    TSocket *sock = new TSocket(gSystem->HostName(), port);
    if(!sock->IsValid()){
      std::cout << "Probably port: " << port << " is closed by the firewall." << std::endl;
      std::cout << "Please use a different port." << std::endl;
      std::cout << "On aino-1/aino-2, port 5901 -- 5999 are open." << std::endl;
      std::cout << "On saho-a/saho-b, port 5901 -- 5999 are open." << std::endl;
      std::cout << "The open port information can be investigated by the linux command: nmap" << std::endl;
      delete sock;
      delete ssocket;
      return 0;
    }
    std::cout << "The port: " << port << " is open on the firewall." << std::endl;
    delete sock;
    */
    delete ssocket;
    
    TString thttpserver_str = Form("http:%d?top=pid%d_at_%s", port, gSystem->GetPid(), gSystem->HostName());
    serv = new THttpServer(thttpserver_str.Data());
    std::cout << "Now you can have access to http://" << gSystem->HostName() << ":"
	      << port << "/" << std::endl;
  }
  /*else{
    if (message_counter < 1) {
      std::cout << "THttpServer is already runing on port " << saved_port << "." << std::endl;
      std::cout << "Access to this THttpServer." << std::endl;
      message_counter++;
    }
    }*/
  return serv;
}

int convert_histo_hbk2root(int id, int kind, TDirectory* cur_dir) {
  char idname[128];
  if (id > 0) snprintf(idname,128,"h%d",id);
  else        snprintf(idname,128,"h_%d",-id);
  int nentries;
  hnoent_(id,nentries);
  if (quest_[0] != 0) {
     std::cout << "quest_[0] != 0 after hnoent subroutine..." << std::endl;
     std::cout << "This may happen during booking of the hbooks. Skip the conversion." << std::endl;
    return 1;
  }
  char chtitl[128];
  int ncx,ncy,nwt,idb;
  float xmin,xmax,ymin,ymax;
  hgive_(id,chtitl,ncx,xmin,xmax,ncy,ymin,ymax,nwt,idb,80);
  int lcid  = hcbook_[10];
  if (lcid <= 0) {
    std::cout << "lcid <= 0 after hgive subroutine..." << std::endl;
    return 1;
  }

  chtitl[4*nwt] = 0;
  std::string chtitl_str = chtitl;
  while (chtitl_str.back() == ' '){
    chtitl_str.pop_back();
  }
  std::string xtitle = "";
  std::string ytitle = "";
  int dlmpos = chtitl_str.find(";");
  if (dlmpos > -1) {
    xtitle = chtitl_str.substr(dlmpos+1);
    chtitl_str = chtitl_str.substr(0,dlmpos);
  }
  dlmpos = xtitle.find(";");
  if (dlmpos > -1) {
    ytitle = xtitle.substr(dlmpos+1);
    xtitle = xtitle.substr(0,dlmpos);
  }
  /*std::string idname_title = Form("%s_%s",idname,chtitl_str.c_str());*/
  std::string idname_title = idname;
  if(hbk_id_title_flag > 0){
    idname_title += "_" + chtitl_str;
    if (hbk_id_title_flag == 2){
      std::stringstream ss("/ , . { } ( ) [ ] ? % # ! & ' - = ~ ^ |");
      std::string tmp_str = "";
      while (ss >> tmp_str){
	while (((int)idname_title.find(tmp_str.c_str())) > -1) {
	  idname_title[idname_title.find(tmp_str.c_str())] = '_';
	}
      }
      while (((int)idname_title.find(" ")) > -1) {
	idname_title[idname_title.find(" ")] = '_';
      }
    }
  }
  TH1* h = (TH1*)cur_dir->TDirectory::FindObject(idname_title.c_str());
  /*std::cout << "h: " << h << std::endl;*/
  int new_flag = 0;
  int cur_kind = 0;
  int *lq = &pawc_[9];
  int *iq = &pawc_[17];
  float *q = (float*)iq;
  if (h) {
    if(h->InheritsFrom("TH2")){
      cur_kind = 2;
    }else if (h->InheritsFrom("TH1")){
      cur_kind = 1;
    }
  }
  if(cur_kind != kind){
    new_flag = 1;
  }
  /* int lcid  = hcbook_[10]; */
  if(kind == 1){
    if(h){
      if(ncx != h->GetXaxis()->GetNbins()){
	new_flag = 1;
      }
      if (hcbits_[5]) {
	int lbins = lq[lcid-2];
	for (int i=0;i<=ncx;i++) {
	  if(q[lbins+i+1] != h->GetXaxis()->GetXbins()->GetArray()[i]){
	    new_flag = 1;
	  }
	}
      }else{
	if((xmin != h->GetXaxis()->GetXmin())||
	   (xmax != h->GetXaxis()->GetXmax())){
	  new_flag = 1;
	}
      }
    }
    if (new_flag == 1){
      if(h){
	delete h;
	h = 0;
      }
      if (hcbits_[5]) {
	int lbins = lq[lcid-2];
	float *xbins = new float[ncx+1];
	for (int i=0;i<=ncx;i++) xbins[i] = q[lbins+i+1];
	TDirectory* cursav = gDirectory;
	cur_dir->cd();
	h = new TH1F(idname_title.c_str(),chtitl_str.c_str(),ncx,xbins);
	/*std::cout << "h->GetName(): " << h->GetName() << std::endl;*/
	cursav->cd();
	delete [] xbins;
      } else {
	TDirectory* cursav = gDirectory;
	cur_dir->cd();
	h = new TH1F(idname_title.c_str(),chtitl_str.c_str(),ncx,xmin,xmax);
	/*std::cout << "h->GetName(): " << h->GetName() << std::endl;*/
	cursav->cd();
      }
      h->GetXaxis()->CenterTitle();
      h->GetYaxis()->CenterTitle();
    }
    /*std::cout << "'" << idname_title.c_str() << "'" << std::endl;*/
    if (hcbits_[8]) h->Sumw2();
    TGraph *gr = 0;
    if (hcbits_[11]) {
      std::cout << "hcbits_[11]:" << hcbits_[11] << std::endl;

      TDirectory* cursav = gDirectory;
      cur_dir->cd();
      gr = new TGraph(ncx);
      cursav->cd();
      h->GetListOfFunctions()->Add(gr);
    }
    float x;
    for (int i=0;i<=ncx+1;i++) {
      x = h->GetBinCenter(i);
      h->SetBinContent(i,hi_(id,i));
      /* if (hcbits_[8])*/
      hsifla_(9,1);
      h->SetBinError(i,hie_(id,i));
      if (gr && i>0 && i<=ncx) gr->SetPoint(i,x,hif_(id,i));
    }
    int kMIN1 = 7;
    int kMAX1 = 8;
    float yymin, yymax;
    if (hcbits_[19]) {
      yymax = q[lcid+kMAX1];
      h->SetMaximum(yymax);
    }
    if (hcbits_[20]) {
      yymin = q[lcid+kMIN1];
      h->SetMinimum(yymin);
    }
    h->SetOption("hist,func");
  }else if (kind==2){
    if(h){
      if((ncx != h->GetXaxis()->GetNbins())||
	 (xmin != h->GetXaxis()->GetXmin())||
	 (xmax != h->GetXaxis()->GetXmax())||
	 (ncy != h->GetYaxis()->GetNbins())||
	 (ymin != h->GetYaxis()->GetXmin())||
	 (ymax != h->GetYaxis()->GetXmax())){
	new_flag = 1;
      }
    }
    if (new_flag == 1){
      if(h){
	delete h;
	h = 0;
      }
      TDirectory* cursav = gDirectory;
      cur_dir->cd();
      h = new TH2F(idname_title.c_str(),chtitl_str.c_str(),ncx,xmin,xmax,ncy,ymin,ymax);
      /*std::cout << "h->GetName(): " << h->GetName() << std::endl;*/
      cursav->cd();
      h->GetXaxis()->CenterTitle();
      h->GetYaxis()->CenterTitle();
    }
    int lcont = lq[lcid-1];
    int lw = lq[lcont];
    if (lw) h->Sumw2();
    for (int j=0;j<=ncy+1;j++) {
      for (int i=0;i<=ncx+1;i++) {
	h->SetBinContent(i,j,hij_(id,i,j));
	if (lw) {
	  float err2 = hije_(id,i,j);
	  h->SetBinError(i,j,err2);
	}
      }
    }
    h->SetOption("colz");
  }
  h->GetXaxis()->SetTitle(xtitle.c_str());
  h->GetYaxis()->SetTitle(ytitle.c_str());
  h->SetEntries(nentries);
  return 0;
}

void convert_dir_hbk2root(const char *cur_dir, TDirectory* output_dir) {
  int idvec[100000];
  int imax = 0;
  std::string cur_dir_str = cur_dir;
  /*std::cout << "cur_dir_str:" << cur_dir_str << std::endl;*/
  hcdir_(cur_dir_str.c_str()," ",cur_dir_str.length(),1);
  hrin_(0,9999,0);
  hidall_(idvec,imax);
  hdelet_(0);
  for (int i=0;i<imax;i++) {
    int id = idvec[i];
    int i999 = 999;
    hrin_(id,i999,0);
    if (quest_[0]) {
      printf("Error cannot read ID = %d\n",id);
      /* break; */
    }
    hdcofl_();
    /*lcid  = hcbook_[10];
      lcont = lq[lcid-1]; */
    if (hcbits_[3]) {
      /* skip ntuple Nobu 20210826
	 if (iq[lcid-2] == 2) convert_rwn(id);
	 else                 convert_cwn(id);*/
      hdelet_(id);
      continue;
    }
    if (hcbits_[0] && hcbits_[7]) {
      /* skip profile Nobu 20210826
	 convert_profile(id);*/
      hdelet_(id);
      continue;
    }
    if (hcbits_[0]) {
      if (convert_histo_hbk2root(id, 1, output_dir)){
	/* std::cout << "Error in convert_histo_hbk2root(id, 1, output_dir)" << std::endl; */
	break;
      }else{
	hdelet_(id);
      }
      continue;
    }
    if (hcbits_[1] || hcbits_[2]) {
      if(convert_histo_hbk2root(id, 2, output_dir)){
	/* std::cout << "Error in convert_histo_hbk2root(id, 2, output_dir)" << std::endl; */
	break;
      }else{
	hdelet_(id);
      }
    }
  }
  /* converting subdirectories of this directory */
  int ndir = 0;
  char subdirs[50][16];
  hrdir_(50, subdirs[0], ndir, 16);
  /*std::cout <<  "ndir: " << ndir << std::endl;*/
  char chdir[17];
  for (int k=0;k<ndir;k++) {
    strlcpy(chdir,subdirs[k],16);
    /*std::cout <<  "subdirs[k]-->" <<  subdirs[k] << "<--" << std::endl;
      std::cout <<  "chdir-->" <<  chdir << "<--" << std::endl;*/
    if (strchr(chdir,'/')) {
      printf("Sorry cannot convert directory name %s because it contains a slash\n",chdir);
      continue;
    }
    /*std::cout << "chdir: " << chdir << std::endl;*/
    chdir[16] = 0;
    for (int i=16;i>0;i--) {
      if (chdir[i] == 0) continue;
      if (chdir[i] != ' ') break;
      chdir[i] = 0;
    }
    /*std::cout << "chdir-->" << chdir << "<--" << std::endl;*/
    std::string chdir_str = chdir;
    TDirectory* new_dir = (TDirectory*)output_dir->TDirectory::FindObject(chdir_str.c_str());
    if (new_dir == 0) {
      new_dir = new TDirectoryFile(chdir_str.c_str(),chdir_str.c_str(),"",output_dir);
    }
    std::string new_cur_dir = cur_dir_str.c_str();
    new_cur_dir = new_cur_dir + "/" + chdir;
    convert_dir_hbk2root(new_cur_dir.c_str(),new_dir);
    hcdir_(cur_dir_str.c_str()," ",cur_dir_str.length(),1);
  }
  return;
}


void shm2srv(const char *shm_name, int port, TDirectory* root_dir) {
  init_hbook(0);
  std::string shm_name_str = open_input_shm(shm_name);
  if(shm_name_str==""){return;}
  THttpServer* serv = open_output_srv(port);
  if (serv == 0) {return;}
  if (root_dir == 0) {root_dir = gROOT;}
  convert_dir_hbk2root(shm_name_str.c_str(), root_dir);
  if (gSystem->ProcessEvents()) {
    std::cout << "Error: gSystem->ProcessEvents() is not null" << std::endl;
  }
  return;
}

void shms2srv(const char *shm_names, int port) {
  init_hbook(0);
  std::string shm_names_str = get_shm_names_str(shm_names);
  std::stringstream ss(shm_names_str);
  std::string shm_name_str;
  while(ss >> shm_name_str){
    if (((int)shm_name_str.find(",")) > -1) {
      shm_name_str[shm_name_str.find(",")] = '_';
    }
    TDirectory* f = (TDirectory*)gROOT->GetListOfFiles()->FindObject(shm_name_str.c_str());
    /*std::cout << "f: " <<  f << std::endl;*/
    if (!f) {
      f = new TMemFile(shm_name_str.c_str(), "recreate");
      /*std::cout << "f->GetName(): " <<  f->GetName() << std::endl;*/
      if (!f) {
	printf("Error: can't open the direcotry: %s\n", shm_name_str.c_str());
	return;
      }
    }
    shm2srv(shm_name_str.c_str(), port, f);
  }
  if(shms2srv_sync_flag == 1){
    int match_flag = 0;
    while (match_flag == 0){
      for (int i = 0; i < gROOT->GetListOfFiles()->GetEntries(); i++){
	TFile* f = (TFile*)gROOT->GetListOfFiles()->At(i);
	std::string classname = f->ClassName();
	match_flag = 0;
	if(classname == "TMemFile"){
	  std::stringstream ss2(shm_names_str);
	  std::string shm_name_str2;
	  while(ss2 >> shm_name_str2){
	    if (((int)shm_name_str2.find(",")) > -1) {
	      shm_name_str2[shm_name_str2.find(",")] = '_';
	    }
	    if (shm_name_str2 == f->GetName()) {
	      match_flag = 1;
	      break;
	    }
	  }
	  if (match_flag == 0){
	    delete f;
	    f = 0;
	    break;
	  }
	}
      }
    }
  }
  return;
}



int main (int argc, char **argv) {
  /* For link option rpath. If the follwoing line is not written and
     LD_LIBRARY_PATH is set, another version of root lib may be loaded. */
  gSystem->Setenv("LD_LIBRARY_PATH","");
  if (argc < 2) {
    std::cout <<"Usage:   shm_monitor port [shm_name_list]" << std::endl;
    std::cout <<"Example: shm_monitor 8080 TEST,FRED" << std::endl;
    std::cout <<"shm_name_list:" << std::endl;
    std::cout <<"    Should be separated by commas with no space." << std::endl;
    std::cout <<"    If an empty string \"\" is given, all shared " << std::endl;
    std::cout <<"    memories will be read." << std::endl;
    std::cout <<"port:" << std::endl;
    std::cout <<"    TCP port number of the THttpServer" << std::endl;
    std::cout <<"Note: This program does not support Ntuples." << std::endl;
    return 0;
  }
  int port;
  std::stringstream ss(argv[1]);
  if (!(ss >> port)) {
    std::cout << "The port number is not valid." << std::endl;
    return 0;
  }
  std::cout << "Type ctrl-c to stop the program." << std::endl;
  while (1) {
    if(argc == 2){
      shms2srv("",port);
    }else{
      shms2srv(argv[2],port);
    }
    if (gSystem->ProcessEvents()) {
      std::cout << "Error: gSystem->ProcessEvents() is not null." << std::endl;
      break;
    }
    gSystem->Sleep(300);
  }
  return 1;
}
