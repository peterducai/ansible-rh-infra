# ansible_cheatsheet

# State

**Think declaratively**

Ansible is a desired state engine by design. If you’re trying to “write code” in your plays and roles, you’re setting yourself up for failure. Our YAML-based playbooks were never meant to be for programming.

**Think about setting state**

With Ansible you setting state of machine (for example.. apache must be installed), where failure means state wasn't set. If setting was SUCCESS, it means state was set (apache was installed) and there is no need to check this state (same way you don't monitor monitoring).

# Naming

Always *name* your plays and tasks. Adding name with a human meaningful description better communicates the intent to users when running a play. 

Use Prefixes and **Human Meaningful Names** with Variables. It is suggested that you define groups based on purpose of the host (roles) and also geography or datacenter location (if applicable).

As a best practice, we recommend prefixing variables with the source or target of the data it represents. Prefixing variables is particularly vital with developing reusable and portable roles.

```shell
apache_max_keepalive: 25
apache_port: 80
tomcat_port: 8080
```

instead of 

```shell
max_keepalive: 25
port: 8080
```

Never use numbering like 'host1, host2..' but think about purpose or quality of object (like 'db-prod, db-test, db-test-london, db-paris-dc1).

# Use Modules Before Run Commands

# Top Level Playbooks Are Separated By Role

In site.yml, we import a playbook that defines our entire infrastructure. This is a very short example, because it’s just importing some other playbooks:

```yaml
---
# file: site.yml
- import_playbook: webservers.yml
- import_playbook: dbservers.yml
```

In a file like webservers.yml (also at the top level), we map the configuration of the webservers group to the roles performed by the webservers group:

```yaml
---
# file: webservers.yml
- hosts: webservers
  roles:
    - common
    - webtier
```


# Tags

## Special

*never* (unless run with specific tag.. test tag in our example) 

```
tasks:
  - debug: msg="{{ showmevar }}"
    tags: [ never, test ]
```

and

*always* which will ignore failure and runs always

## Run only tasks with specific tags

> ansible-playbook example.yml --tags "configuration,packages"

# Conditionals

```
tasks:
    - name: Restart Apache on webservers
      become: yes
      service:
        name: apache2
        state: restarted
      when: webservers in group_names
```

```
tasks:
  - include: Ubuntu.yml
    when: ansible_os_family == "Ubuntu"
  
  - include: RHEL.yml
    when: ansible_os_family == "RedHat"
```

```
ansible_distribution in ['RedHat', 'CentOS', 'ScientificLinux'] and
  (ansible_distribution_version|version_compare('7', '<')
```


# LOGS

```
task:
  - name: Fetch a log file
    fetch: 
      src=C:/mylog.txt
      dest=/home/user/mylog.txt
      flat=yes
  - name: process logs
    shell: cat /home/user/mylog.txt
    register: log_content
  - shell: echo "log contains the word Error"
    when: log_content.stdout.find('Error') != -1
```

OR

```
  - name: find errors in file
    shell: grep /home/user/mylog.txt
    register: err_content
  - shell: echo "No errors found"
    when: err_content.stdout.find('Error') = -1
```


# What This Organization Enables (Examples)

Above we’ve shared our basic organizational structure.

Now what sort of use cases does this layout enable? Lots! If I want to reconfigure my whole infrastructure, it’s just:

> ansible-playbook -i production site.yml

To reconfigure NTP on everything:

> ansible-playbook -i production site.yml --tags ntp

To reconfigure just my webservers:

> ansible-playbook -i production webservers.yml

For just my webservers in Boston:

> ansible-playbook -i production webservers.yml --limit boston

For just the first 10, and then the next 10:

```shell
ansible-playbook -i production webservers.yml --limit boston[0:9]
ansible-playbook -i production webservers.yml --limit boston[10:19]
```

And of course just basic ad-hoc stuff is also possible:

```shell
ansible boston -i production -m ping
ansible boston -i production -m command -a '/sbin/reboot'
```

And there are some useful commands to know:

confirm what task names would be run if I ran this command and said "just ntp tasks"

> ansible-playbook -i production webservers.yml --tags ntp --list-tasks

confirm what hostnames might be communicated with if I said "limit to boston"

> ansible-playbook -i production webservers.yml --limit boston --list-hosts

