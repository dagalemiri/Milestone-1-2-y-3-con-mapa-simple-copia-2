//
//  chatGrupal.swift
//  MMMilestone2
//
//  Created by David Galemiri on 13-05-15.
//  Copyright (c) 2015 mecolab. All rights reserved.
//

import UIKit


class chatGrupal: UIViewController,UITableViewDataSource,UITableViewDelegate {
    //Outlets y variables
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var controller: UIViewController!
    var authDone = false
    var conversaciones = [ConversacionGrupal]()
    var selected = NSIndexPath()
  
    //Metodo que baja las conversaciones del servidor
    func bajarConversacionesDelServidor() {
        interaccionServidor.obtenerConversacionesUsuario(estaticos.numeroUsuario())
        self.obtenerConversaciones()
    }
    
    //Metodo que obtiene las conversaciones de la base de datos
    func obtenerConversaciones() {
        self.conversaciones = estaticos.Fetch("ConversacionGrupal") as! [ConversacionGrupal]
        self.tableView.reloadData()
    }
    
    // Metodo que crea las celdas
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("celdaChatGrupal") as! celdaChatGrupal
        cell.id.text = conversaciones[conversaciones.count-1-indexPath.row].id.stringValue
        cell.nombre.text = conversaciones[conversaciones.count-1-indexPath.row].titulo
        cell.numero.text = estaticos.buscarNumeroEnAgenda(conversaciones[conversaciones.count-1-indexPath.row].numeroAdmin)
        return cell
    }
    
    //Numero de filas por seccion
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversaciones.count
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        controller = self
        tableView.dataSource = self
        tableView.delegate = self
        bajarConversacionesDelServidor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //Evento que se activa al presionar una celda
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selected = NSIndexPath(forRow: conversaciones.count-indexPath.row-1, inSection: 0)
        print(selected.row)
        //Metodo que llama el segue
        controller.performSegueWithIdentifier("salaChatGrupal", sender: controller)
    }
    
    // Metodo que se llama antes de crear el view controller del segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "salaChatGrupal" {
            let controller:salaChatGrupal = segue.destinationViewController as! salaChatGrupal
            controller.content = conversaciones[selected.row].titulo
            controller.id = conversaciones[selected.row].id.stringValue
        }
    }

    //Evento que se activa al presionar el boton refresco
    @IBAction func refrescar(sender: AnyObject) {
        self.bajarConversacionesDelServidor()
    }
}
