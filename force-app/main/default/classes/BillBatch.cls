public with sharing class BillBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {
    
    public List<Id> receivesBillByEmail = new List<Id>();
    
    public Database.QueryLocator start(Database.BatchableContext bc) {

        String query = 'SELECT Id,Bill_By_Email__c FROM Account WHERE Active__c = \'Yes\' AND Bill_By_Email__c != null';
        return Database.getQueryLocator(query);

    }

    public void execute(Database.BatchableContext bc, List<Account> scope){

        BillAPI.getBills();

        for(Account a: scope){
            if(a.Bill_By_Email__c == true){
                receivesBillByEmail.add(a.Id);
            }
        }
    }

    public void finish(Database.BatchableContext bc){
    
        Map<Id,Id> billMap = new Map<Id,Id>();
        Map<Id,String> emailMap = new Map<Id,String>();
        Map<String, Blob> emailsWithBills = new Map<String, Blob>();

        List<Account> accList = [SELECT Id, Email__c, (SELECT Id FROM Bills__r ORDER BY CreatedDate DESC) FROM Account WHERE Id IN : this.receivesBillByEmail];
        
        for(Account a: accList){
            billMap.put(a.Id,a.Bills__r[0].Id);
            emailMap.put(a.Id,a.Email__c);
        }
        
        for(Id accId: billMap.keyset()){
            PageReference pageRef = new PageReference('/apex/BillVFP?id=' + billMap.get(accId));
            Blob pdfBlob = pageRef.getContentAsPDF();
            emailsWithBills.put(emailMap.get(accId), pdfBlob); 
        }

        if(emailsWithBills.size() > 0){
            BillEmailer.sendEmails(emailsWithBills);
        }


    }
}