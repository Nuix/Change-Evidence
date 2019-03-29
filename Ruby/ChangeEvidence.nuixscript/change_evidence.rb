# Menu Title: Change Evidence Location
# Needs Case: true

require 'rexml/document'
require 'java'
require 'fileutils'
import javax.swing.JOptionPane
import javax.swing.JCheckBox
import javax.swing.JButton
import javax.swing.JDialog
import javax.swing.JFrame
import java.awt.GridLayout

# Class for dialog with checkboxes
class CheckDialog < JDialog
  def initialize(items)
    @containers = items
    @checkboxes = items.map do |c|
      JCheckBox.new("#{c.get_name}; #{c.get_uri[9..-5]}", true)
    end

    super nil, true
    initUI
  end

  def initUI
    button = JButton.new('Select')
    button.addActionListener do |_e|
      dispose
    end
    boxes = @checkboxes.size + 1
    height = 30 + boxes * 30
    setTitle('Evidence Containers')
    @checkboxes.each do |c|
      getContentPane.add(c)
    end
    getContentPane.add(button)
    getContentPane.setLayout GridLayout.new(boxes, 1)
    setDefaultCloseOperation JFrame::DISPOSE_ON_CLOSE
    setSize 400, height
    setLocationRelativeTo nil
    setVisible true
  end

  def selected
    containers = []
    @checkboxes.each_with_index do |c, i|
      containers << @containers[i] if c.is_selected
    end
    containers
  end
end

# Module for selecting a directory
module Chooser
  java_import javax.swing.JFileChooser

  def self.dir(initial_d = nil, title = nil)
    dc = JFileChooser.new
    dc.setFileSelectionMode(JFileChooser::FILES_AND_DIRECTORIES)
    dc.setCurrentDirectory(java.io.File.new(initial_d)) unless initial_d.nil?
    dc.setDialogTitle(title) unless title.nil?
    return nil unless dc.showOpenDialog(nil) == JFileChooser::APPROVE_OPTION

    dc.getSelectedFile.getAbsolutePath
  end
end

# Reads XML files.
#
# @param item [Item] a Nuix evidence container item
# @param location [String] location including case path
# @return [Hash] of XML location and hash representation
def get_xml(item, location)
  xml_location = File.join(location, item.get_uri.split(':')[1])
  xml_file = File.new(xml_location)
  xml_doc = REXML::Document.new xml_file
  xml_file.close
  { xml_location => xml_doc }
end

# Gets evidence XML files. Handles compound cases.
#
# @param case1 [Case] a Nuix case
# @return [Hash] of XML location and hash representation
def get_xmls(case1)
  xmls = {}
  if case1.is_compound
    case1.get_child_cases.each { |child| xmls.merge!(get_xmls(child)) }
  else
    xmls_location = File.join(case1.get_location.to_s, 'Stores', 'Evidence')
    root_items = case1.get_root_items
    return get_xml(root_items[0], xmls_location) if root_items.size == 1

    dlg = CheckDialog.new(root_items)
    dlg.selected.each do |container|
      xmls.merge!(get_xml(container, xmls_location))
    end
  end
  xmls
end

begin
  if !$current_case.nil?
    xmls = get_xmls($current_case)
    xmls.each do |evidence_xml, xml_doc|
      xml_doc.context[:attribute_quote] = :quote
      name = xml_doc.elements['evidence/name'].get_text.to_s
      o_location = xml_doc.elements['evidence/data-roots/data-root/file location'].attributes['location']
      next unless JOptionPane.showConfirmDialog(nil, "Evidence location: #{o_location}\n" + 'Do you want to change this location?', name, JOptionPane::YES_NO_OPTION) == JOptionPane::YES_OPTION

      if JOptionPane.showConfirmDialog(nil, 'Do you want to backup the XML file?', name, JOptionPane::YES_NO_OPTION) == JOptionPane::YES_OPTION
        backup = evidence_xml + Time.now.strftime('%d%m%Y__%H%M') + '.bak'
        FileUtils.cp(evidence_xml, backup)
      end
      location = Chooser.dir(o_location, 'Select Evidence Location')
      if !location.nil?
        msg = "Old: #{o_location}\n" + "New: #{location}\n"
        if JOptionPane.showConfirmDialog(nil, msg + "Update #{evidence_xml}?", name, JOptionPane::YES_NO_OPTION) == JOptionPane::YES_OPTION
          xml_doc.elements['evidence/data-roots/data-root/file location'].attributes['location'] = location
          output = ""
          xml_doc.write(:output => output, :ie_hack => true)
          IO.write(evidence_xml, output)
          JOptionPane.showMessageDialog(nil, "Updated #{name}\n" + msg + 'Close and re-open your case for the changes to take effect.')
        end
      else
        JOptionPane.showMessageDialog(nil, 'Exiting: No location selected.')
      end
    end
  else
    JOptionPane.showMessageDialog(nil, 'No case selected.')
  end
end
