//
//  imagenesViewController.swift
//  MMMilestone2
//
//  Created by David Galemiri on 10-08-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit

class imagenesViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

    
    @IBOutlet weak var url: UIImageView!
    let imagePicker = UIImagePickerController()
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()


          imagePicker.delegate = self
        
        
        if let url = NSURL(string: "http://guasapuc.herokuapp.com/system/message_contents/contents/000/000/148/original/1441634969528.jpg?1441634972") {
            if let data = NSData(contentsOfURL: url){
                imageView.contentMode = UIViewContentMode.ScaleAspectFit
                imageView.image = UIImage(data: data)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func libreria(sender: AnyObject)
    {
        
        imagePicker.allowsEditing = false
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        
        
        presentViewController(imagePicker, animated: true, completion: nil)
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        {
            imageView.contentMode = .ScaleAspectFit
            imageView.image = pickedImage
            dismissViewControllerAnimated(true, completion: nil)
            
            let imageData = UIImageJPEGRepresentation(imageView.image!, 1.0)
            SRWebClient.POST("http://guasapuc.herokuapp.com/api/v2/conversations/send_file_message")
                .data(imageData!, fieldName:"file",
                    data:[
                        "file_mime_type":"image/jpeg",
                        "conversation_id":"146",
                        "sender":estaticos.numeroUsuario()
                    ])
                .headers(["Authorization":estaticos.formatoToken()])
                .send({(response:AnyObject!, status:Int) -> Void in
                    //process success response
                    NSLog(response.description)
                    },failure:{(error:NSError!) -> Void in
                        //process failure response
                        NSLog(error.description)
                })
            
        }
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
   

    
    @IBAction func enviarImagen(sender: AnyObject)
    {
 
      
        
        
        
        
        
        let request=NSMutableURLRequest(URL:NSURL(string:"http://guasapuc.herokuapp.com/api/v2/conversations/send_file_message")!)
        request.HTTPMethod="POST"
        let image = UIImage(named: "fondo1.jpg")
        let imageData = UIImageJPEGRepresentation(image!, 1.0)
        request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
        request.timeoutInterval = 60
        request.HTTPShouldHandleCookies = false
        let boundary = "unique-consistent-string"
        let contentType = "multipart/form-data; boundary=\(boundary)"
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(estaticos.formatoToken(),forHTTPHeaderField:"Authorization")
        var body = NSMutableData()
        body.appendData("conversation_id=146&sender=56968799501&file=".dataUsingEncoding(NSUTF8StringEncoding)!)
        

        
     /*   body.appendData(NSString(string: "\r\n--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        
            body.appendData(NSString(string: "Content-Disposition: form-data; name=fondo1; filename=fondo1.jpg\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData("Content-Type: image/jpeg\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
            body.appendData(imageData!)
            body.appendData(NSString(string: "\r\n--\(boundary)\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)*/
        body.appendData(imageData!)
        body.appendData("&file_mime_type=image/jpeg".dataUsingEncoding(NSUTF8StringEncoding)!)
        
        
    
        var postLength = "\(body.length)"
        request.HTTPBody = body
        request.setValue(postLength,forHTTPHeaderField:"Content-Length")
        


        

        
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request){ data, response,error -> Void in
        
            print(data)
            var jsonSwift : AnyObject? = try? NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers)
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print(responseString, terminator: "")
            print(error, terminator: "")
            
            
            
            //  println("responseString = \(responseString)")
            if let jsonArray = jsonSwift as? NSArray
            {
                for jsonContacto in jsonArray
                {
                    
                    if let diccionarioContacto = jsonContacto as? Dictionary<String,NSObject>
                    {
                        
                        print(diccionarioContacto, terminator: "")
                    }
                }
            }

        }
        task.resume()
        
        



        
    
        
     
        
        
    }
    


    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
