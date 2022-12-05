class ProjectDTO{
  int _ProjectID = 0;
  String _ProjectName = "";
  String _ProjectDescription = "";
  String _ImageUrl = "";
  double _Rating = 0;
  String _Status = "";
  String _MarkDown = "";
  String _fileHex = "";
  String _ProposerAddress = "";
  ProjectDTO(this._ProjectID,this._ProjectName,this._ProjectDescription,this._ImageUrl,this._Rating,this._Status,this._MarkDown,this._fileHex,this._ProposerAddress);
  int get ProjectID => _ProjectID;
  String get ProjectName => _ProjectName ;
  String get ProjectDescription => _ProjectDescription ;
  String get ImageUrl => _ImageUrl ;
  double get Rating => _Rating ;
  String get Status => _Status ;
  String get MarkDown => _MarkDown ;
  String get fileHex => _fileHex ;
  String get ProposerAddress => _ProposerAddress ;

  set ProjectID(int newProjectID){
    _ProjectID = newProjectID;
  }
  set ProjectName(String newProjectName){
    _ProjectName = newProjectName;
  }
  set ProjectDescription(String newProjectDescription){
    _ProjectDescription = newProjectDescription;
  }
  set ImageUrl(String newImageUrl){
    _ImageUrl = newImageUrl;
  }
  set Rating(double newRating){
    _Rating = newRating;
  }
  set Status(String newStatus){
    _Status = newStatus;
  }
  set MarkDown(String newMarkDown){
    _MarkDown = newMarkDown;
  }
  set newfileHex(String newfileHex){
    _fileHex = newfileHex;
  }
  set newProposerAddress(String newProposerAddress){
    _fileHex = newProposerAddress;
  }

  Map<String,dynamic> toMap(){
    var map = Map<String,dynamic>();
    map[""] = _ProjectID;
    map[""] = _ProjectName;
    map[""] = _ProjectDescription;
    map[""] = _ImageUrl;
    map[""] = _Rating;
    map[""] = _Status;
    map[""] = _MarkDown;
    map[""] = _fileHex;
    map[""] = _ProposerAddress;
    return map;
  }
  ProjectDTO.fromObject(dynamic o){
    this._ProjectID = o["projectID"];
    this._ProjectName = o["projectName"];
    this._ProjectDescription = o["projectDescription"];
    this._ImageUrl = o["imageUrl"];
    this._Rating = o["rating"];
    this._Status = o["status"];
    this._MarkDown = o["markDown"];
    this._fileHex = o["fileHex"];
    this._ProposerAddress = o["proposerAddress"];
  }
}

