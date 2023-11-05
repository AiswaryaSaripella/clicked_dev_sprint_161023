public with sharing class BillEmailer {
    
    public static void sendEmails(Map<String, Blob> emailsWithBills) {

        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        for(String email : emailsWithBills.keySet()) {
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            List<String> bccEmails = new List<String>();
            bccEmails.add(email);
            mail.setBccAddresses(bccEmails);
            mail.PlainTextBody = 'Hi! Here is your latest bill';
            mail.Subject = 'Latest Bill';

            //attach the PDF blob to the email:
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            attach.Body = emailsWithBills.get(email);
            attach.FileName = 'Bill-' + Date.Today().Month() + '-' + Date.Today().Day() + '-' + Date.Today().Year() + '.pdf';
            attach.ContentType = 'application/pdf';

            mail.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});

            //add the Messaging.SingleEmailMessage object to the list inside of the loop, and send the email outside of the loop.
            emailsToSend.add(mail);
        }

        Messaging.SendEmailResult[] results = Messaging.sendEmail(emailsToSend);
        // Call a helper method to inspect the returned results
        inspectResults(results);
    }

    //this is a method that will allow you to check to see if your code works.
    private static Boolean inspectResults(Messaging.SendEmailResult[] results) {
        Boolean sendResult = true;
        for (Messaging.SendEmailResult res : results) {
            if (res.isSuccess()) {
                System.debug('Email sent successfully');
            }
            else {
                sendResult = false;
                System.debug('The following errors occurred: ' + res.getErrors());                 
            }
        }
        return sendResult;
    }
}