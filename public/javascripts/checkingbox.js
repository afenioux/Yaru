/* 
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
checked=false;
function checkedAll (frm1) {
	var aa= document.getElementById(frm1);
	 if (checked == false)
          {
           checked = true
          }
        else
          {
          checked = false
          }
	for (var i =0; i < aa.elements.length; i++)
	{
	 aa.elements[i].checked = checked;
	}
      }
